const express = require('express')
const core = require('cors')
const path = require('path');
const Product = require('./Management/Product')
const Book = require('./Management/Book')
const Unit = require('./Management/Unit')
const Category = require('./Management/Category')
const User = require('./Management/User')
const Import = require('./Management/Import')
const Supplier = require('./Management/Supplier')
const Role = require('./Management/Role')
const Author = require('./Management/Authors')
const Sellhy = require('./Management/Sales_History')
const Activitylog = require('./Management/Activitylog')
const Dashboard = require('./Management/Dashboard');
const Backup = require('./backup');

const app = express()
app.use(express.json())
app.use(core())
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

app.use('/main', Sellhy)
app.use('/main', Author)
app.use('/main', Product)
app.use('/main', Book)
app.use('/main', Unit)
app.use('/main', Category)
app.use('/main', User)
app.use('/main', Import)
app.use('/main', Supplier)
app.use('/main', Role)
app.use('/main', Activitylog)
app.use('/main', Dashboard); 
app.use('/main', Backup); 

app.listen(3000,()=> console.log('Server is running on port 3000'))