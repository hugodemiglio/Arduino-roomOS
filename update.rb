# Hugo Demiglio
# Ruby controller 1.0.0

# encoding: utf-8
require 'serialport'

class ArduinoRoomOS
  @@status_negra = false
  @@status_branca = false
  
  def initialize
    self.start_connection
    
    self.get_info
    self.show_info
    
    self.change_branca if !@@status_branca
    self.update_time
    
    @@sp.close
  end
  
  def start_connection
    print "Iniciando conexao..."

    status_negra = false
    status_branca = true

    port_str = "/dev/tty.arduino"

    baud_rate = 9600
    data_bits = 8
    stop_bits = 1
    parity = SerialPort::NONE

    @@sp = SerialPort.new(port_str, baud_rate, data_bits, stop_bits, parity)

    puts " [ OK ]"
  end
  
  def get_info
    print "Obtendo informações..."
    @@sp.write("I")
    i = @@sp.gets.chomp
    puts " [ OK ]"

    info = i.split("|")
    
    @@status_branca = info[0] == '0' ? false : true
    @@status_negra = info[1] == '0' ? false : true
  end
  
  def show_info
    puts "\nEstado atual do Arduino\n"
    puts "Luz Branca: #{@@status_branca ? 'acesa' : 'apagada'}"
    puts "Luz Negra: #{@@status_negra ? 'acesa' : 'apagada'}"
    puts ""
  end
  
  def update_time
    print "Atualizando data e hora..."
    @@sp.write("T")
    @@sp.write(Time.now.day.chr)
    @@sp.write(Time.now.month.chr)
    @@sp.write(Time.now.hour.chr)
    @@sp.write(Time.now.min.chr)
    @@sp.write(Time.now.sec.chr)
    puts " [ OK ]"
  end
  
  def change_branca
    print "#{@@status_branca ? 'Apagando' : 'Acendendo'} luz Branca..."
    @@sp.write("B")
    puts " [ OK ]"
  end
  
  def change_negra
    print "#{@@status_negra ? 'Apagando' : 'Acendendo'} luz Negra..."
    @@sp.write("N")
    puts " [ OK ]"
  end
  
  def serial_streaming
    while true do
      while (i = sp.gets.chomp) do
        puts i
      end
    end
  end
  
end

ArduinoRoomOS.new