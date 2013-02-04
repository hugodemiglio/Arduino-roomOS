#include <LiquidCrystal.h>
#include <IRremote.h>

LiquidCrystal lcd(7, 6, 5, 4, 3, 2);

//Reles
int luzNegra = 8, luzBranca = 12;

//Variaveis de ambiente
int statusNegra = 0, statusBranca = 0, resposta, i, ultimoTemp = 0, segundo = 0, leds = 11, pushVar = 0, menu = 0, quedaEnergia = 1;

//Variaveis Seriais
int serial_read, bt_update = 0;

//Controler do LCD
int lcdLedStatus = 0, lcdLedTime = 1, lcdStatus = 1;

//Caracteres
byte termometro[8] = {B00100, B01010, B01010, B01110, B01110, B11111, B11111, B01110};
byte bolinha[8] = {B01100, B10010, B10010, B01100, B00000, B00000, B00000, B00000};
byte b1[8] = {B01111, B10000, B10000, B10000, B10000, B10000, B10000, B01111};
byte b3[8] = {B11111, B11111, B11111, B11111, B11111, B11111, B11111, B11111};
byte b4[8] = {B11110, B11111, B11111, B11111, B11111, B11111, B11111, B11110};
byte b5[8] = {B01111, B11111, B11111, B11111, B11111, B11111, B11111, B01111};
byte b7[8] = {B11111, B00000, B00000, B00000, B00000, B00000, B00000, B11111};
byte b8[8] = {B11110, B00001, B00001, B00001, B00001, B00001, B00001, B11110};

//Sistema de temperatura
int tempc = 0, samples[8], tempertura = A0;

//Teclado
int tecla = 0, tecladoPin = A1, ultimoBotao = 0, turnOn = 0;

//Uptime das luzes
int uhora = 0, uminuto = 0, usegundo = 0;

//Controle de consumo
float wbranca = 0.66, wnegra = 0.33, tconsumo = 0;
int consumo = 0;

// Relógio e calendário
int dia = 1, mes = 1, ano = 13, hora = 0, minuto = 0, segundos = 0, relogioSegundo = 0;

//Sistema de infravermelho
int valorIR = 0;
IRrecv irrecv(10);
decode_results results;

void setup() {
  //pinMode(leds, OUTPUT);
  //analogWrite(leds, 5);
  digitalWrite(leds, HIGH);
  //analogWrite(leds, 20);
  irrecv.enableIRIn();
  Serial.begin(9600);
  
  //Pinos
  pinMode(luzBranca, OUTPUT);
  pinMode(luzNegra, OUTPUT);
  
  lcd.begin(16,2);
  lcd.createChar(0, termometro);
  lcd.createChar(1, bolinha);
  
  lcd.createChar(2, b1);
  lcd.createChar(3, b3);
  lcd.createChar(4, b4);
  
  lcd.createChar(5, b5);
  lcd.createChar(6, b7);
  lcd.createChar(7, b8);
  
  analogWrite(9, 100);
  lcd.setCursor(0, 0);
  lcd.print("HG Room OS 1.3.0");
  lcd.setCursor(0, 1);
  lcd.print("   Bem-vindo!   ");
  delay(3000);
  statusNegra = apagar(luzNegra);
  statusBranca = apagar(luzBranca);
}

void loop() {
  segundo = millis()/1000;
  
  tecla = teclado(tecladoPin);
  acoes();
  
  if(Serial.available() > 0) {
    serial_read = Serial.read();
    switch (serial_read){
      case 'I':
        Serial.print(statusBranca);
        Serial.print("|");
        Serial.print(statusNegra);
        Serial.print("|");
        Serial.println(tempc);
      break;
      case 'N':
        if(statusNegra == 0){
          statusNegra = acender(luzNegra);
        } else {
          statusNegra = apagar(luzNegra);
        }
      break;
      case 'B':
        if(statusBranca == 0){
          statusBranca = acender(luzBranca);
        } else {
          statusBranca = apagar(luzBranca);
        }
      break;
      case 'T':
        bt_update = 1;
      break;
      default:
        serial_update(serial_read);
        Serial.println(serial_read);
      break;
    }
  }
  
  if (irrecv.decode(&results)) {
    //Serial.println(results.value);
    if(results.value == 3782895767){
      if(statusBranca == 0){
        statusBranca = acender(luzBranca);
      } else {
        statusBranca = apagar(luzBranca);
      }
    }
    if(results.value == 2011254978){
      if(menu == 0) statusBranca = acender(luzBranca);
      else menuAction(1);
    }
    if(results.value == 2011246786){
      if(menu == 0) statusBranca = apagar(luzBranca);
      else menuAction(0);
    }
    if(results.value == 2011259074){
      if(menu == 0) statusNegra = acender(luzNegra);
      else menuAction(1);
    }
    if(results.value == 2011271362){
      if(menu == 0) statusNegra = apagar(luzNegra);
      else menuAction(0);
    }
    if(results.value == 2011283650){
      menuNext();
      if(quedaEnergia == 1) quedaEnergia = 0;
    }
    lcd.setCursor(10, 0);
    valorIR = (results.value);
    //Serial.println(results.value);
    irrecv.resume();
 }
  
  if(menu == 0){
    exibirTemperatura(segundo, ultimoTemp);
    push();
    showRelogio();
  } else {
    mainMenu();
  }
  
  lcdLedTimer();
  relogioLoop();
  controleLoop();
  cron();
  //debug();
  
  delay(200);
  if(segundo == (ultimoTemp + 5)){
    pushNext();
    ultimoTemp = segundo;
    turnOn = 1;
  }
}

int acender(int luz){
  digitalWrite(luz, LOW);
  zerarControle();
  ultimoTemp = segundo;
  pushVar = 2;
  if(luz == luzBranca){
    analogWrite(9, 100);
    //digitalWrite(leds, LOW);
  }
  return 1;
}

int apagar(int luz){
  digitalWrite(luz, HIGH);
  zerarControle();
  if(luz == luzBranca){
    analogWrite(9, 5);
    //digitalWrite(leds, HIGH);
  }
  return 0;
}

void lcdLedTimer(){
  if(statusBranca == 0 && statusNegra == 0){
    if(lcdLedStatus == 0){
      lcdLedTime = segundo + 30;
      lcdLedStatus = 1;
    } else {
      if(lcdLedTime <= segundo){
        analogWrite(9, 0);
        if(statusBranca == 0 && statusNegra == 0) {
          if(lcdStatus == 1){
            lcdStatus = 0;
            lcd.clear();
          }
        }
      }
    }
  } else {
    if(lcdLedStatus == 1) analogWrite(9, 100);
    lcdLedStatus = 0;
  }
}

void acoes(){
  if (tecla != ultimoBotao && turnOn == 1) {
    if(tecla == 1){
      if(statusBranca == 0){
        statusBranca = acender(luzBranca);
      } else {
        statusBranca = apagar(luzBranca);
      }
    }
  }
  ultimoBotao = tecla;
}

void relogioLoop(){
  if(segundo > relogioSegundo || segundo < relogioSegundo){
    relogioSegundo = segundo;
    segundos = segundos + 1;
    usegundo = usegundo + 1;
  }
  if(segundos >= 60){
    minuto = minuto + 1;
    segundos = 0;
  }
  if(mes >= 13){
    ano = ano + 1;
    mes = 1;
  }
  if(dia >= 32){
    mes = mes + 1;
    dia = 1;
  }
  if(minuto >= 60){
    hora = hora + 1;
    minuto = 0;
  }
  if(hora >= 24){
    dia = dia + 1;
    hora = 0;
  }
  if(hora < 0){
    hora = 0;
  }
  if(minuto < 0){
    minuto = 0;
  }
}

void controleLoop(){
  if(statusBranca == 1 || statusNegra == 1){
    consumo = (tconsumo * (uminuto + (uhora * 60)));
    if(usegundo >= 60){
      uminuto = uminuto + 1;
      usegundo = 0;
    }
    if(uminuto >= 60){
      uhora = uhora + 1;
      uminuto = 0;
    }
    if(uhora >= 99){
      uhora = 0;
    }
    if(uhora < 0){
      uhora = 0;
    }
    if(uminuto < 0){
      uminuto = 0;
    }
  }
}

void showRelogio(){
  if(lcdStatus == 1){
    lcd.setCursor(5, 1);
    showInt(dia);
    lcd.print("/");
    showInt(mes);
    lcd.print(" ");
    showInt(hora);
    lcd.print(":");
    showInt(minuto);
  }
}

void showLightUptime(){
  if(uhora == 0) showInt(uminuto);
  else showInt(uhora);
  lcd.print(":");
  if(uhora == 0) showInt(usegundo);
  else showInt(uminuto);
}

void showInt(int valor){
  if(lcdStatus == 1){
    if(valor <= 9) lcd.print("0");
    lcd.print(valor);
  }
}

void cron(){
  //Desliga a luz branca as 02:00
  if(hora == 2 && minuto == 0){
    if(statusBranca == 1) statusBranca = apagar(luzBranca);
  }
  
  //Desliga a luz branca apos 4 horas ligada
  if(statusBranca == 1 && uhora >= 4) statusBranca = apagar(luzBranca);
  
  //Ativa o display de LCD
  if(statusBranca == 1 || statusNegra == 1) {
    if(lcdStatus == 0){
      lcdStatus = 1;
      limparTela();
    }
  }
}

void debug(){
  lcd.setCursor(5, 1);
  resposta = teclado(tecladoPin);
  lcd.print(resposta);
  lcd.print("K ");
  lcd.print(segundo);
  lcd.print("      ");
}

void exibirTemperatura(int seg, int ultimo){
  tempc = 0;
  lcd.setCursor(0, 1);
  if(lcdStatus == 1) lcd.write(0);
  for(i = 0;i<=7;i++){
    samples[i] = ( 5.0 * analogRead(tempertura) * 100.0) / 1024.0;
    tempc = tempc + samples[i];
    delay(10);
  }

  tempc = (tempc/8.0) - 4;
  if(segundo == (ultimo + 5)){
    if(lcdStatus == 1){
      lcd.print(tempc);
      lcd.write(1);
      lcd.print(" ");
    }
  }
}

void zerarControle(){
  consumo = 0;
  uhora = 0;
  uminuto = 0;
  usegundo = 0;
}

void limparTela(){
  lcd.setCursor(0, 0);
  lcd.print("   Carregando   ");
  lcd.setCursor(0, 1);
  lcd.write(0);
  lcd.print("--");
  lcd.write(1);
  lcd.print(" 00/00 00:00");
}

int teclado(int tecladoPin){
  int valor;
  valor = analogRead(tecladoPin);
  
  if(valor > 130 && valor < 190){
    return 1;
  } else if(valor > 870 && valor < 899){
    return 2;
  } else if(valor > 400 && valor < 499){
    return 3;
  } else if(valor > 800 && valor < 860){
    return 4;
  } else if(valor > 700 && valor < 799){
    return 5;
  } else if(valor > 600 && valor < 699){
    return 6;
  } else {
    return 0;
  }
}

void push(){
  lcd.setCursor(0, 0);
  
  if(lcdStatus == 1){
    switch(pushVar){
      /* Mostra o status das luzes */
      case 0:
        if(statusBranca == 0 && statusNegra == 0){
          lcd.print(" Luzes apagadas ");
          tconsumo = 0;
        } else {
          if(statusBranca == 1 && statusNegra == 1){
            lcd.print("  Luzes acesas  ");
            tconsumo = wbranca + wnegra;
          } else {
            if(statusBranca == 1){
              lcd.print("Luz branca acesa");
              tconsumo = wbranca;
            } else {
              lcd.print("Luz negra acesa");
              tconsumo = wnegra;
            }
          }
        }
        break;
      
      /* Mostra o consumo de energia da luz */
      case 1:
        if(statusBranca == 0 && statusNegra == 0){
          pushNext();
        } else {
          showLightUptime();
          lcd.print("   ");
          showInt(consumo);
          lcd.print(" Watts   ");
        }
        break;
      
      /* Mostra os lembretes de contas */
      case 2:
        switch(dia){
          case 1:
            lcd.print("Pagar parc. Carro");
            break;
          case 9:
            lcd.print("Pagar cart. VISA");
            break;
          case 10:
            lcd.print("Pagar cart. BB  ");
            break;
          case 15:
            lcd.print("Pagar Submarino ");
            break;
          case 21:
            lcd.print("Pagar MasterCard");
            break;
          default:
            lcd.print("Nenhum lembrete.");
            break;
        }
        break;
        
      case 3:
        if(quedaEnergia == 1) {
          lcd.print("Queda de Energia");
        } else {
          pushNext();
        }
        break;
      
      /* Mostra o status da temperatuda */
      case 4:
        if(tempc <= 18){
          lcd.print(" Ambiente frio  ");
        } else if(tempc >= 26){
          lcd.print("Ambiente quente ");
        } else {
          lcd.print("Temp. agradavel ");
        }
        break;
    
      /* Mostra a versao do sistema */
      case 5:
        lcd.print("HG Room OS 1.3.0");
        break;
    }
  }
}

void pushNext(){
  if(pushVar == 5){
    pushVar = 0;
  } else {
    pushVar = pushVar + 1;
  }
}

void menuNext(){
  if(menu == 6){
    menu = 0;
    limparTela();
  } else {
    menu = menu + 1;
  }
}

void menuAction(int mode){
  switch(menu){
    case 1:
      if(mode == 1) hora = hora + 1;
      else hora = hora - 1;
      if(hora >= 24) hora = 0;
      if(hora < 0) hora = 23;
      break;
    case 2:
      if(mode == 1) minuto = minuto + 1;
      else minuto = minuto - 1;
      if(minuto >= 60) minuto = 0;
      if(minuto < 0) minuto = 59;
      break;
    case 3:
      if(mode == 1) dia = dia + 1;
      else dia = dia - 1;
      if(dia >= 32) dia = 0;
      if(dia < 0) dia = 31;
      break;
    case 4:
      if(mode == 1) mes = mes + 1;
      else mes = mes - 1;
      if(mes >= 13) mes = 0;
      if(mes < 0) mes = 12;
      break;
    case 5:
      if(statusBranca == 1) statusBranca = apagar(luzBranca);
      else statusBranca = acender(luzBranca);
      break;
    case 6:
      if(statusNegra == 1) statusNegra = apagar(luzNegra);
      else statusNegra = acender(luzNegra);
      break;
  }
}

void mainMenu(){
  lcd.setCursor(0, 0);
  switch(menu){
    case 1:
      lcd.print(" Ajuste da hora ");
      lcd.setCursor(0, 1);
      lcd.print("   -   ");
      showInt(hora);
      lcd.print("   +   ");
      break;
    case 2:
      lcd.print(" Ajuste minuto ");
      lcd.setCursor(0, 1);
      lcd.print("   -   ");
      showInt(minuto);
      lcd.print("   +   ");
      break;
    case 3:
      lcd.print(" Ajuste do dia ");
      lcd.setCursor(0, 1);
      lcd.print("   -   ");
      showInt(dia);
      lcd.print("   +   ");
      break;
    case 4:
      lcd.print(" Ajuste do mes ");
      lcd.setCursor(0, 1);
      lcd.print("   -   ");
      showInt(mes);
      lcd.print("   +   ");
      break;
    case 5:
      lcd.print("   Luz branca   ");
      lcd.setCursor(0, 1);
      if(statusBranca == 1) {
        lcd.print("  ligada   ");
        lcd.write(2);
        lcd.write(6);
        lcd.write(3);
        lcd.write(4);
      } else {
        lcd.print(" desligada ");
        lcd.write(5);
        lcd.write(3);
        lcd.write(6);
        lcd.write(7);
      }
      lcd.print(" ");
      break;
    case 6:
      lcd.print("   Luz  negra   ");
      lcd.setCursor(0, 1);
      if(statusNegra == 1) {
        lcd.print("  ligada   ");
        lcd.write(2);
        lcd.write(6);
        lcd.write(3);
        lcd.write(4);
      } else {
        lcd.print(" desligada ");
        lcd.write(5);
        lcd.write(3);
        lcd.write(6);
        lcd.write(7);
      }
      lcd.print(" ");
      break;
  }
}

void serial_update(int serial_data){
  switch (bt_update){
    case 1:
      dia = serial_data;
      bt_update++;
    break;
    case 2:
      mes = serial_data;
      bt_update++;
    break;
    case 3:
      hora = serial_data;
      bt_update++;
    break;
    case 4:
      minuto = serial_data;
      bt_update++;
    break;
    case 5:
      segundos = serial_data;
      bt_update = 0;
    break;
    default:
      bt_update = 0;
    break;
  }
}