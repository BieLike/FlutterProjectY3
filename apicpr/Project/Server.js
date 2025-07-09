const mysql = require('mysql')


class Database{
    constructor(){
        this.db = mysql.createConnection({
            host: "localhost",//192.168.222.224  /pe 192.168.189.1/192.168.100.9
            user: 'root',//Team  /pe  be
            password: '',//123456  /pe 123
            database: 'dbcpr',
            port:3306
        })
        this.connect()

    }
    
    
    connect(){
        this.db.connect((err)=>{
            if(err){
                console.log('Can not connect Mysql database!!!')
                return
            }
            console.log('Mysql database connected')
        })
    }

    getConnection(){
        return this.db
    }
}

module.exports = Database

