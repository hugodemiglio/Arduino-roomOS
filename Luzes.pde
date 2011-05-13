#include <LiquidCrystal.h>
#include <IRremote.h>

LiquidCrystal lcd(7, 6, 5, 4, 3, 2);

//Reles
int luzNegra = 8, luzBranca = 12;

//Variaveis de ambiente
int statusNegra = 0, statusBranca = 0, lcdLedStatus = 0, lcdLedTime = 1, resposta, i, ultimoTemp = 0, segundo = 0, leds = 11;

//Caracteres
byte termometro[8] = {B00100, B01010, B01010, B01110, B01110, B11111, B11111, B01110};
byte bolinha[8] = {B01100, B10010, B01100, B00000, B00000, B00000, B00000, B00000};

//Sistema de temperatura
int tempc = 0, samples[8], tempertura = A0;

//Teclado
int tecla = 0, tecladoPin = A1, ultimoBotao = 0, turnOn = 0;

// Relógio e calendário
int dia = 12, mes = 5, ano = 11, hora = 21, minuto = 4, segundos = 0, relogioSegundo = 0;

//Sistema de infravermelho
int valorIR = 0;
IRrecv irrecv(10);
decode_results results;

void setup() {
  //digitalWrite(leds, HIGH);
  //analogWrite(leds, 20);
  irrecv.enableIRIn();
  //Serial.begin(9600);
  
  //Pinos
  pinMode(luzBranca, OUTPUT);
  pinMode(luzNegra, OUTPUT);
  
  lcd.begin(16,2);
  lcd.createChar(0, termometro);
  lcd.createChar(1, bolinha);
  analogWrite(9, 100);
  lcd.setCursor(0, 0);
  lcd.print("HG RoomOS 1.0.2");
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
  
  if (irrecv.decode(&results)) {
    if(results.value == 3782895767){
      if(statusBranca == 0){
        statusBranca = acender(luzBranca);
      } else {
        statusBranca = apagar(luzBranca);
      }
    }
    if(results.value == 2011287612){
      statusBranca = acender(luzBranca);
    }
    if(results.value == 2011279420){
      statusBranca = apagar(luzBranca);
    }
    if(results.value == 2011291708){
      statusNegra = acender(luzNegra);
    }
    if(results.value == 2011238460){
      statusNegra = apagar(luzNegra);
    }
    if(results.value == 2011250748){
      statusNegra = apagar(luzNegra);
      statusBranca = apagar(luzBranca);
    }
    lcd.setCursor(10, 0);
    valorIR = (results.value);
    //Serial.println(results.value);
    irrecv.resume();
 }
  
  exibirTemperatura(segundo, ultimoTemp);
  statusLuzes();
  lcdLedTimer();
  relogioLoop();
  showRelogio();
  //debug();
  
  cron();
  
  delay(200);
  if(segundo == (ultimoTemp + 5)){
    ultimoTemp = segundo;
    turnOn = 1;
  }
}

int acender(int luz){
  digitalWrite(luz, LOW);
  if(luz == luzBranca){
    analogWrite(9, 100);
    //digitalWrite(leds, LOW);
  }
  return 1;
}

int apagar(int luz){
  digitalWrite(luz, HIGH);
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

void showRelogio(){
  lcd.setCursor(5, 1);
  showInt(dia);
  lcd.print("/");
  showInt(mes);
  lcd.print(" ");
  showInt(hora);
  lcd.print(":");
  showInt(minuto);
}

void showInt(int valor){
  if(valor <= 9) lcd.print("0");
  lcd.print(valor);
}

void cron(){
  if(hora == 2 && minuto == 0){
    if(statusBranca == 1) statusBranca = apagar(luzBranca);
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
 lcd.setCursor(0, 1);
 lcd.write(0);
 for(i = 0;i<=7;i++){
  samples[i] = ( 5.0 * analogRead(tempertura) * 100.0) / 1024.0;
  tempc = tempc + samples[i];
  delay(10);
 }

 tempc = (tempc/8.0) - 4;
 if(segundo == (ultimo + 5)){
  lcd.print(tempc);
  lcd.write(1);
  lcd.print(" ");
 }
 tempc = 0;
}

void statusLuzes(){
  lcd.setCursor(0, 0);
  if(statusBranca == 0 && statusNegra == 0){
    lcd.print(" Luzes apagadas ");
  } else {
    if(statusBranca == 1 && statusNegra == 1){
      lcd.print("  Luzes acesas  ");
    } else {
      if(statusBranca == 1){
        lcd.print("Luz branca acesa");
      } else {
        lcd.print("Luz negra acesa");
      }
    }
  }
  
  if(statusBranca == 0){
    analogWrite(9, 5);
    digitalWrite(leds, HIGH);
  } else {
    analogWrite(9, 100);
    digitalWrite(leds, LOW);
  }
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


