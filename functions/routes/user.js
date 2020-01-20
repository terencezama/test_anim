
const admin = require('firebase-admin');
const JsonError = require('../jsonerror')
const { check, validationResult } = require('express-validator/check');
module.exports = function(app){


    app.get('/users',async (req,res)=>{
        let {query:{nextPageToken}} = req
        try{
            let result = await admin.auth().listUsers(20,nextPageToken);
            let users = []
            result.users.forEach(user=>{
                users.push({...user,passwordHash:undefined,passwordSalt:undefined})
            })
            res.status(200).json(users)
        }catch(error){
            console.log('error>>',error)
            res.status(400).json({error});
        }
    })
    app.post('/users', async(req,res)=>{
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
    
    app.put('/user/:id', async(req,res)=>{
        let id = req.params.id;
        let body = req.body;
        let {role,displayName} = req.body;
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
        try{
            let result = await admin.auth().updateUser(id,body)
            await admin.auth().setCustomUserClaims(id,{role:role})
            res.json({status:"ok"})
        }catch(error){
            res.status(400).json({error})
        }
    })
    app.delete('/users', async(req,res)=>{
        let ids = req.query.ids
        ids.forEach(id => {
            admin.auth().deleteUser(id)    
        });
        res.status(200).send({status:"ok"})
    })

}