
const admin = require('firebase-admin');
const JsonError = require('../jsonerror')
const { check, validationResult } = require('express-validator/check');
module.exports = function(app){


app.get('/meals',[

],async(req,res)=>{
    try{
        let result  = undefined
        let query   = undefined
        if (req.query.id){
            query   = admin.firestore().collection('meals').where("userId","==",req.query.id).orderBy('date')
        }else{
            query  = admin.firestore().collection('meals').orderBy('date')
        }

        let{query:{nextPageToken,limit}} = req;
        if (limit){
            query = query.limit(parseInt(limit))
        }

        if (nextPageToken){
            query = query.startAfter(admin.firestore().collection('meals').doc(nextPageToken))
        }
        result      = await query.get()
        let meals = [];
        result.docs.forEach(doc=>{
            let data = doc.data()
            meals.push({
                id:doc.ref.id,
                ...data,
                date:data.date.toDate()
            })
        })
        res.json(meals)
    }catch(error){
        console.log(error)
        res.status(400).json({error});
    }
    
})
app.post('/meals',[
    check("date").isString(),
    check("time").isString(),
    check("text").isString(),
    check("calories").isInt(),
    check("userId").isString(),
],async(req,res)=>{
    
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        res.status(422).json({ error: errors.array() });
        return;
    }
    
    let {body:{date,time,text,calories,userId}} = req;
    try {
       let docRef = await admin.firestore().collection('meals').add({
            date:new Date(date),
            time:time,
            text,
            calories:parseInt(calories),
            userId
        })
        res.json({id:docRef.id})
    } catch (error) {
        res.status(400).json({error});
    }
})
app.put('/meal/:id', async(req,res)=>{
    let id = req.params.id;
    let body = req.body;
    
    try{
        await admin.firestore().collection('meals').doc(id).update({
            ...body
        })
        res.json({status:"ok"})
        
    }catch(error){
        res.status(400).json({error});
    }
})
app.delete('/meals',[
    check("ids","should contain an array of ids").isArray()
], async(req,res)=>{
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        res.status(422).json({ error: errors.array() });
        return;
    }
    try{
        let batch = admin.firestore().batch();
        let ids = req.query.ids
        ids.forEach(id =>{
            let docRef = admin.firestore().collection('meals').doc(id)
            batch.delete(docRef)
        })
        await batch.commit()
        res.json({status:"ok"})
    }catch(error){
        res.status(400).json({error});
    }
})

}