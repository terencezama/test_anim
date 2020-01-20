'use strict';

const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();
const express = require('express');
const cookieParser = require('cookie-parser')();
const cors = require('cors')({origin: true});
const app = express();
const JsonError = require('./jsonerror')
const nodemailer = require("nodemailer");
const qrcode = require('qrcode-js');


let transporter = nodemailer.createTransport({
    // host: "smtp.gmail.com",
    // port: 25,
    // secure: false, // true for 465, false for other ports
    service:'gmail',
    auth: {
      user: functions.config().app.email.username, // generated ethereal user
      pass: functions.config().app.email.password // generated ethereal password
    },
    // tls: {
    //     rejectUnauthorized: false
    // }
  });

  //#region Authorization
const validateFirebaseIdToken = async (req, res, next) => {
  console.log('Check if request is authorized with Firebase ID token');

  if (
      (!req.headers.authorization || !req.headers.authorization.startsWith('Bearer ')) &&
      !(req.cookies && req.cookies.__session) &&
      !req.headers["Access-Type"]

      ) {
    console.error('No Firebase ID token was passed as a Bearer token in the Authorization header.',
        'Make sure you authorize your request by providing the following HTTP header:',
        'Authorization: Bearer <Firebase ID Token>',
        'or by passing a "__session" cookie.');
    res.status(403).send('Unauthorized');
    return;
  }

  let idToken;
  if (req.headers.authorization && req.headers.authorization.startsWith('Bearer ')) {
    console.log('Found "Authorization" header');
    // Read the ID Token from the Authorization header.
    idToken = req.headers.authorization.split('Bearer ')[1];
  } else if(req.cookies) {
    console.log('Found "__session" cookie');
    // Read the ID Token from cookie.
    idToken = req.cookies.__session;
  } else {
    // No cookie
    res.status(403).send('Unauthorized');
    return;
  }

  try {
    let accessType = req.headers["access-type"]
    if (accessType === 'apikey'){
        if (idToken !== functions.config().app.apikey){
            throw new Error("Access Not Valid");
        }
    }else if (accessType === 'firebaseid'){
        const decodedIdToken = await admin.auth().verifyIdToken(idToken);
        console.log('ID Token correctly decoded', decodedIdToken);
        req.user = decodedIdToken;
    }else{
        throw new Error("accessType Undefined");
    }
    
    next();
    return;
  } catch (error) {
    console.error(error);
    res.status(403).send('Unauthorized');
    return;
  }
};

//#endregion
app.use(cors);
app.use(cookieParser);
app.use(validateFirebaseIdToken);
app.get('/test', (req, res) => {
  res.json({
      'headers':req.headers["access-type"],
  })
});

//#region Email Template
function sendCodeEmail(email,code){
    const mailOptions = {
        from: `KCAL Support <support@kcal.com>`,
        to: email
    }
    var base64 = qrcode.toDataURL(code,4)
    mailOptions.subject = 'Password Reset email';
    mailOptions.html = `<p><strong style="
    font-size: xx-large;
">${code}</strong></p><p><img src="cid:qrcode@kcal.com"/></p></p>`

    mailOptions.attachments = [{
        fileName: "cat.jpg",
        path:base64,
        cid: 'qrcode@kcal.com'
    }]
    console.log("mailoptions",JSON.stringify(mailOptions))
    return transporter.sendMail(mailOptions);
}
//#endregion
//#region Registration
app.post('/register',async (req,res) =>{
    let {username:email,password,role,displayName} = req.body;
    /*Perform field checks */
    if(!email){
        res.status(400).json({error:JsonError('auth/username_required',"Username is required")});
        return;
    } 
    if (!password){
        res.status(400).json({error:JsonError('auth/password_required',"Password is required")});
        return;
    } 
    if (role){
        if(role !== "user" && role !== "manager" && role !== "admin"){
            res.status(400).json({error:JsonError('auth/role_unspecified',"The role you provided is not specified.")})
            return;
        }
    } 
    if (!displayName){
        res.status(400).json({error:JsonError('auth/displayname_required',"DisplayName is required")});
        return;
    }

    try {
        let user = await admin.auth().createUser({email,password,displayName})
        let claim = role ? role : "user"
        await admin.auth().setCustomUserClaims(user.uid,{role:claim})
        var result = { ...user, role:claim}
        res.json(result)

    } catch (error) {
        res.status(400).json({error});
    }
    
})
//#endregion
//#region Forgot Password
app.get('/forgotpassword',async (req,res) =>{
    let {email} = req.query;
    if(!email){
        res.status(400).json({error:JsonError('auth/email_required',"Email is required")});
        return;
    }

    //Check if user exists or end
    try{
        await admin.auth().getUserByEmail(email);
    }catch(error){
        res.status(400).json({error});
        return;
    }
    

    let code = getRandomInt(10000,1000000)
    let spacedCode = spaceDelimitedInt(code);

    //Send User email about code
    try{
        await sendCodeEmail(email,spacedCode)
        res.status(200).json({message:'A mail with the reset code has been sent to your inbox.'})
    }catch(error){
        res.status(400).json({error});
    }

    //append code to firestore
    let resetCodes = admin.firestore().collection("resetcodes")
    try{
        let exists = await resetCodes.where("email","==",email).get()
        if(exists.size > 0){
            let doc = exists.docs[0]
            await doc.ref.delete()
        }
        resetCodes.add({
            attempts:0,
            code,
            email,
            isValidated:false
        })
    }catch(error){
        console.error("firestore",error)
    }
})
app.get('/verify', async (req,res) =>{
    let {email,code,type} = req.query;
    //#region Type Check
    if(!email){
        res.status(400).json({error:JsonError('auth/email_required',"Email is required")});
        return;
    }

    if(!code){
        res.status(400).json({error:JsonError('auth/code_required',"code Field is required")});
        return;
    }

    if(!type || type !== "forgot_password"){
        res.status(400).json({error:JsonError('auth/type_required',"type Field is required")});
        return;
    }
    //#endregion
    let resetCodes = admin.firestore().collection("resetcodes")
    try{
        let exists = await resetCodes.where("email","==",email).get()
        if(exists.size > 0){
            let doc = exists.docs[0]
            let data = doc.data()
            if(data.isValidated === false){
                code = parseInt(code.replace(/ /g,''))
                if(data.code === code){
                    doc.ref.update({
                        isValidated:true
                    })
                    res.json({message:'success'})
                }else{
                    // console.log(data.code,code)
                    res.status(400).json({error:JsonError('auth/code_mismatch',"The code you provided is wrong.")})
                }
                
            }else{
                res.status(400).json({error:JsonError('auth/code_already_validated',"The code you provided has already been validated")})
            }
            
        }else{
            res.status(400).json({error:JsonError('auth/code_mismatch',"The code you provided is wrong.")})
        }
    }catch(error){
        res.status(400).json({error})
    }



})
app.put('/reset', async (req,res)=>{
    let {code,password} = req.body;
    if(!code){
        res.status(400).json({error:JsonError('auth/code_required',"code Field is required")});
        return;
    }else if (!password){
        res.status(400).json({error:JsonError('auth/password_required',"Password is required")});
        return;
    }

    let resetCodes = admin.firestore().collection("resetcodes")
    var email = ""
    try{
        code = parseInt(code.replace(/ /g,''))
        let exists = await resetCodes.where("code","==",code).get()
        if(exists.size > 0){
            let doc = exists.docs[0]
            email = doc.data().email
            doc.ref.delete()
            
        }else{
            res.status(400).json({error:JsonError('auth/code_not_found',"code not found")})
            return;
        }
    }catch(error){
        res.status(400).json({error:JsonError('auth/code_not_found',"code not found")})
        return;
    }

    try{
        let user = await admin.auth().getUserByEmail(email)
        await admin.auth().updateUser(user.uid,{password})
        res.send({message:"success"})
        
    }catch(error){
        res.status(400).json({error:JsonError('auth/user_not_found',"User not found")})
    }
})
//#endregion

//#region Users
require('./routes/user')(app);
//#endregion

require('./routes/meal')(app);

//#region Utils
function getRandomInt(min, max) {
    min = Math.ceil(min);
    max = Math.floor(max);
    return Math.floor(Math.random() * (max - min + 1)) + min;
}
function spaceDelimitedInt(value){
    let arr = `${value}`.split("");
    var result = ""
    for (let i = 0; i < arr.length; i++) {
        let el = arr[i];
        result += el
        if(i !== arr.length-1){
            result += " "
        }
    }
    return result
}
//#endregion
exports.app = functions.https.onRequest(app);