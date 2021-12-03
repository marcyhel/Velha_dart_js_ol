


const Velha={
    tabuleiro:null,
    socket:null,
    container:null,
    comandos:null,
    init:function(container){
        this.comandos=Comandos
        this.comandos.init(this)
        this.container=container
        //this.start()
    },
    conec:function(){
        this.conecta()
        this.tabuleiro=Jogo
        this.tabuleiro.init(this.container,this)
    },
    start:function(){
        
        this.draw()
    },
    conecta:function(){
        this.socket = new WebSocket('ws://186.207.129.17:8080')
        soc=this.socket
        comand=this.comandos
        tab =this.tabuleiro
        star=this.start
        this.socket.onopen = function(event) {
            console.log('WebSocket is connected.')
            
            
            
        };
        //this.envia('{"id":"nick","nick":"mar"}')
        this.socket.onmessage = function(event) {
            var message = event.data
            comand.command(JSON.parse(message))
            //comand(JSON.parse(message),tab,star)
        };
    },
   // {"id":"att","x":1,"y":2,"marc":1}
    
    envia:function(mesagem){
        this.socket.send(mesagem);
        console.log(mesagem)
        
    },
    click:function(x,y){
        this.tabuleiro.click(x,y)
    },
    draw:function(){
        this.tabuleiro.draw()
    }
}
const Comandos={
    velha:null,
    init:function(velha){
        this.velha=velha
    },
    command:function(mensagem){
        console.log(mensagem['id'])
        
        
        if(mensagem['id']=='att') this.velha.tabuleiro.marcar( mensagem['x'] , mensagem['y'] , mensagem['marc'] )
        if(mensagem['id']=='id'){
            
            this.velha.tabuleiro.id=mensagem['ident']
            this.velha.tabuleiro.eu=(mensagem['ident']==1)?"X":"O"
            this.velha.socket.send('{"id":"nick","nick":"'+document.getElementById('nick').value+'" }')
        }
        if(mensagem['id']=='nickOP') this.velha.tabuleiro.oponente=mensagem['nick']
        if(mensagem['id']=='vez') this.velha.tabuleiro.vez=(mensagem['vez']==1)?"X":"O"
        this.velha.draw()
    }
}
const Jogo={
    board:[],
    container:null,
    velha:null,

    oponente:null,
    eu:null,
    vez:null,
    id:null,
    init:function(container,velha){
        this.container=container
        this.velha=velha
        
        for(var i=0;i<3;i++){
            var aux=[]
            for(var j=0;j<3;j++){
                aux.push('')
            }
            this.board.push(aux)
        }
        
        
    },
    marcar:function(x,y,marca){
        if(marca==1)this.board[x][y]="X";
        if(marca==2)this.board[x][y]="O";
        
        this.draw()
    },
    click:function(x,y){
        console.log(x,y)
        if(this.board[x][y]=='b'){
            console.log("falha")
            return false
        }
        this.velha.socket.send(JSON.stringify({'id':'jogada','jogada':x+' '+y}))
        
        this.draw()
    },
    draw:function(){
        let content='<div class="opo">Oponente: '+this.oponente+'</div>'
        content+='<div class="vez">Vez do: '+this.vez+'</div>'
        content+='<div class="eu">Voçe é: '+this.eu+'</div>'
        
        content+="<div class='game'>"
       
        for( i in this.board){
           
            for (j in this.board[0]){
                
                content+='<div onclick="Velha.click('+i+','+j+')">'+this.board[i][j]+'</div>'
            }
            
        }
        content+="</div>"
        
        this.container.innerHTML=content
        console.log(this.board)
    }
}
