import 'dart:io';
import 'dart:convert';

class Cliente {
  int id;
  String nick = '';
  int pontos = 0;
  bool reset = false;
  WebSocket conect;
  Cliente(this.id, this.conect) {}
}

class Sala {
  List<Cliente> clientes = [];
  List<String> nick = [];
  int vez_jogador = 1;
  bool vencedor = false;
  List<List<int>> tab = [
    [0, 0, 0],
    [0, 0, 0],
    [0, 0, 0]
  ];
  Sala() {}
  bool lance(x, y) {
    if (tab[x][y] == 0) {
      tab[x][y] = vez_jogador;
      return true;
    } else {
      return false;
    }
  }

  void alterna() {
    if (vez_jogador == 1) {
      vez_jogador = 2;
    } else {
      vez_jogador = 1;
    }
  }

  bool verifica() {
    int vence = 0;
    for (var i = 0; i < tab.length; i++) {
      if (tab[0][i] == tab[1][i] && tab[1][i] == tab[2][i] && tab[0][i] != 0) {
        vence = tab[0][i];
        vencedor = true;
        break;
      }
      if (tab[i][0] == tab[i][1] && tab[i][1] == tab[i][2] && tab[i][0] != 0) {
        vence = tab[i][0];
        vencedor = true;
        break;
      }
    }
    if (tab[0][0] == tab[1][1] && tab[1][1] == tab[2][2] && tab[0][0] != 0) {
      vence = tab[0][0];
      vencedor = true;
    }
    if (tab[0][2] == tab[1][1] && tab[1][1] == tab[2][0] && tab[0][2] != 0) {
      vence = tab[0][2];
      vencedor = true;
    }

    if (vencedor) {
      if (clientes[0].id == vence) {
        clientes[0].pontos += 1;
        print("dd");
      } else {
        clientes[1].pontos += 1;
        print("gg");
      }
      print(vence);
    }
    return vencedor;
  }

  void chamadas(msns, client) {
    try {
      var msn = json.decode(msns);
      print(msn);
      if (msn['id'] == 'nick') {
        print("au");
        client.nick = msn['nick'];
        print(client.nick);
        print("---");
        sendOthers(
            json.encode({'id': 'nickOP', 'nick': client.nick}), client.conect);
        sendOthers(json.encode({'id': 'desenha'}), client.conect);
        sendOthers(
            json.encode({'id': 'vez', 'vez': vez_jogador}), client.conect);
      }
      if (msn['id'] == 'reset') {
        vencedor = false;
        client.reset = true;
        if (clientes[0].reset && clientes[1].reset) {
          clientes[0].reset = false;
          clientes[1].reset = false;
          sendAll(json.encode({
            'id': 'reset',
            'vez': vez_jogador,
          }));
          tab = [
            [0, 0, 0],
            [0, 0, 0],
            [0, 0, 0]
          ];
        }
      }
      if (msn['id'] == 'jogada') {
        if (client.id == vez_jogador && !vencedor) {
          try {
            var aux = msn['jogada'].split(' ');
            if (lance(int.parse(aux[0]), int.parse(aux[1]))) {
              print(tab);
              sendAll(json.encode({
                'id': 'att',
                'x': int.parse(aux[0]),
                'y': int.parse(aux[1]),
                'marc': vez_jogador
              }));
              sendAll(json.encode({'id': 'desenha'}));
              alterna();
              sendAll(json.encode({'id': 'vez', 'vez': vez_jogador}));
              if (verifica()) {
                sendAll(json.encode({'id': 'fim', 'msn': "fim de partida"}));
                sendAll(json.encode({
                  'id': 'pontos',
                  'x': clientes[0].id == 1
                      ? clientes[0].pontos
                      : clientes[1].pontos,
                  'o': clientes[0].id == 2
                      ? clientes[0].pontos
                      : clientes[1].pontos
                }));
              }
            } else {
              client.conect.add(json.encode(
                  {'id': 'erro', 'erro': 'jogada invalida\njogue novamente'}));
            }
          } catch (e) {
            client.conect
                .add(json.encode({'id': 'erro', 'erro': 'comando invalida'}));
          }
        } else {
          client.conect.add(
              json.encode({'id': 'erro', 'erro': 'Não é sua vez de jogar'}));
        }
      }
    } catch (e) {
      print('Erro');
    }
  }

  void inicia() {
    escutar();
    print("aquiiiop");
    clientes.forEach((e) {
      e.conect.add(json.encode({'id': 'id', 'ident': e.id}));
    });
  }

  void escutar() {
    clientes.forEach((element) {
      element.conect.listen((event) {
        print(event);
        // print("dd");
        //sendOthers(event, element.conect);
        chamadas(event, element);
      });
    });
  }

  void sendOthers(mensagem, WebSocket exeption) {
    clientes.forEach((element) {
      if (element.conect != exeption) {
        element.conect.add(mensagem);
      }
    });
  }

  void sendAll(mensagem) {
    clientes.forEach((element) {
      element.conect.add(mensagem);
    });
  }

  void addCliente(cliente) {
    clientes.add(cliente);
  }
}

main() {
  List<Sala> salas = [];
  var sala = Sala();
  print('rodando');
  HttpServer.bind('192.168.176.1', 8080).then((server) {
    server.listen((HttpRequest request) {
      WebSocketTransformer.upgrade(request).then((cliente) {
        print("conect");
        // cliente.add(sala.clientes.length.toString());

        if (sala.clientes.length < 2) {
          sala.addCliente(Cliente(sala.clientes.length + 1, cliente));
        }
        if (sala.clientes.length == 2) {
          //sala.sendAll("");
          sala.inicia();
          salas.add(sala);
          sala = Sala();
        }
      });

      //request.response.write('Hello, world!');
      //request.response.close();
    }, onDone: () {
      print("desconectou");
    });
  });
}
