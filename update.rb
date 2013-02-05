# encoding: utf-8

# Hugo Demiglio
# Ruby controller 1.0.0
require 'serialport'
require 'terminfo'
require 'time'

class ArduinoRoomOS
  @@version = '1.0.0 beta'
  
  @@port_str = "/dev/tty.arduino"
  @@light = [1 => true, 2 => true]
  @@power_outage = false
  @@arduino_time = Time.now
  @@success = false
  @@startup = true
  @@temperatura = 0
  
  def initialize
    system("clear")
    puts "\n     ###   ###  #######"
    puts '     ###   ### ###'
    puts '     ######### ###   ###'
    puts '     ###   ### ###   ###'
    puts '     ###   ###  #######'
    puts "\n HGRoomOS - Serial Controller"
    puts "     #{@@version} - 2013 ®\n\n"
    
    self.show_progress 0, 3, "Iniciando sistema..."
    sleep 1
    
    self.start_connection
    
    if @@success
      self.get_info
      self.change_light(1) if !@@light[1]
      self.update_time
    
      self.show_info
    
      self.menu
    
      # @@sp.close
      system('clear')
    end
    
    puts "\n HGRoomOS - Serial Controller #{@@version}"
    puts " http://hgbrasil.com - Hugo Demiglio - 2013"
    puts " Programa finalizado com sucesso.\n\n"
  end
  
  def menu
    inside_menu = true
    
    while inside_menu
      puts "\n Ações disponíveis:"
      puts " 1 - #{@@light[1] ? 'Apagar' : 'Acender'} luz branca"
      puts " 2 - #{@@light[2] ? 'Apagar' : 'Acender'} luz negra"
      puts " 3 - Obter novamente os dados"
      puts " 4 - Exibir os dados obtidos"
      puts " 5 - Atualizar data e hora"
      puts " 6 - Ver streaming da porta serial"
      puts " Q - Sair"
      print "\n Sua escolha: "
      choise = gets
      
      reprint_menu = false
      up_lines = 10
      while !reprint_menu
        reprint_menu = false
        
        case choise.gsub(/\s+/, "")
          when "1"
            self.change_light 1
            reprint_menu = true
          when "2"
            self.change_light 2
            reprint_menu = true
          when "3"
            up_lines += 2
            self.get_info
            print " Entre com uma nova escolha: "
          when "4"
            self.show_info
            reprint_menu = true
          when "5"
            up_lines += 2
            self.update_time
            print " Entre com uma nova escolha: "
          when "6"
            self.serial_streaming
            reprint_menu = true
          when "Q"
            inside_menu = false
            reprint_menu = true
          else
            up_lines += 1
            print " Opção inválida, entre com uma nova: "
        end
        lines_size = TermInfo.screen_size[0]
        if up_lines > lines_size && lines_size > 15
          reprint_menu = true
          puts ""
        end
        choise = gets if !reprint_menu
      end
    end
  end
  
  def show_progress current, total, message, force_progress = false
    if @@startup || force_progress
      size = TermInfo.screen_size[1]
      bar_size = size - message.length - 5
    
      $stdout.flush
      percent = (bar_size * current) / total
    
      print " #{message} ["
      bar_size.times do |i|
        if i <= percent
          print "="
        else
          print " "
        end
      end
      print "]\r"
    else
      print " #{message}"
    end
  end
  
  def clear_line message = ''
    size = TermInfo.screen_size[1] - 1
    size.times do |i|
      $stdout.flush
      print " "
    end
    print "\r"
    print message if !message.empty?
  end
  
  def start_connection
    self.show_progress 1, 3, "Iniciando conexao..."
    status_negra = false
    status_branca = true
    
    baud_rate = 9600
    data_bits = 8
    stop_bits = 1
    parity = SerialPort::NONE
    
    try = 3
    while(try > 0)
      begin
        @@sp = SerialPort.new(@@port_str, baud_rate, data_bits, stop_bits, parity)
        @@success = true
        try = 0
      rescue
        self.clear_line
        puts " Iniciando conexão #{4 - try}/3... \033[91m[ FAIL ]\033[0m"
        try = try - 1
        self.show_progress 1, 3, "Tentando novamente..."
      end
    end
    
    if @@success
      self.clear_line
      puts " Iniciando conexão... \033[92m[ OK ]\033[0m"
    else
      self.clear_line
      puts "\n Ocorreu um erro na conexão serial. \033[91m[ FAIL ]\033[0m"
      puts " Infelizmente não foi possível continuar."
      puts " Tente novamente, ou verifique se a porta serial (#{@@port_str}) está disponível."
    end
  end
  
  def get_info
    self.show_progress 2, 3, "Obtendo informações..." if @@startup
    
    try = 3
    while(try > 0)
      begin
        self.show_progress 2, 3, "Obtendo informações..."
                
        @@sp.write("I")
        sleep 1
        i = @@sp.gets.chomp
        
        info = i.split("|")
        
        @@light[1] = info[0] == '0' ? false : true
        @@light[2] = info[1] == '0' ? false : true
        @@temperatura = info[2].to_i
        @@power_outage = info[3] == '0' ? false : true
        @@arduino_time = Time.parse(info[4])
        
        self.clear_line " Obtendo informações..." if @@startup
        puts " \033[92m[ OK ]\033[0m"
        try = 0
      rescue
        self.clear_line " Obtendo informações..." if @@startup
        puts " #{4 - try}/3 \033[91m[ FAIL ]\033[0m"
        try = try - 1
      end
    end
    
  end
  
  def show_info
    puts "\n ╔════════════════════════╗"
    puts " ║ Estado atual do Quarto ║"
    puts " ╠════════════════════════╩═══════════════════════════════════╗"
    self.show_info_line "Luz Branca: #{@@light[1] ? 'acesa' : 'apagada'}"
    self.show_info_line "Luz Negra: #{@@light[2] ? 'acesa' : 'apagada'}"
    self.show_info_line "Temeratura do ambiente: #{@@temperatura < 10 ? '0'+@@temperatura.to_s : @@temperatura}"
    if @@power_outage
      time_out = self.secunds_to_string(@@arduino_time - Time.parse('2013-1-1 0:0:0'))
      puts " ╠════════════════════════════════════════════════════════════╣"
      self.show_info_line "Queda de energia detectada"
      self.show_info_line "Tempo desde a queda de energia: #{time_out}"
    else
      self.show_info_line "Última data obtida: #{@@arduino_time.strftime('%d/%m/%Y %H:%M')}"
    end
    puts " ╚════════════════════════════════════════════════════════════╝\n"
  end
  
  def show_info_line message, size = 63
    print " ║ #{message}"
    (size - (message.length + 4)).times do
      print " "
    end
    puts "║"
  end
  
  def update_time
    self.show_progress 3, 3, "Atualizando data e hora..."
    @@sp.write("T")
    @@sp.write(Time.now.day.chr)
    @@sp.write(Time.now.month.chr)
    @@sp.write(Time.now.hour.chr)
    @@sp.write(Time.now.min.chr)
    @@sp.write(Time.now.sec.chr)
    self.clear_line
    puts " Atualizando data e hora... \033[92m[ OK ]\033[0m"
    @@startup = false
  end
  
  def change_light id
    self.clear_line
    print " #{@@light[id] ? 'Apagando' : 'Acendendo'} luz #{id == 1 ? 'branca' : 'negra'}..."
    
    try = 3
    while(try > 0)
      begin
        self.clear_line " Tentando novamente..." if try != 3
        @@sp.write("#{id == 1 ? 'B' : 'N'}")
        puts " \033[92m[ OK ]\033[0m"
        @@light[id] = !@@light[id]
        try = 0
      rescue
        puts " #{4 - try}/3 \033[91m[ FAIL ]\033[0m"
        try = try - 1
      end
    end
    
  end
  
  def serial_streaming
    system("clear")
    puts "\n Serial Streaming: "
    puts " Para sair, precione Control + C"
    puts ""
    in_loop = true
    while in_loop do
      begin
        while (i = @@sp.gets.chomp) do
          puts i
        end
        sleep 0.1
      rescue
        in_loop = false
      end
    end
  end
  
  def secunds_to_string secs
    units = {
      "semana" => 7*24*3600,
      "dia" => 24*3600,
      "hora" => 3600,
      "minuto" => 60,
      "segundo" => 1,
    }
    
    return "0 segundos" if secs == 0
    
    s = ""

    i = 0
    units.each do |name,divisor|
      if(quot = (secs / divisor).to_i) != 0
        next if i > 1
        s += "#{quot} #{name}"
        s += (quot.abs > 1 ? "s" : "") + " e "
        secs -= quot * divisor
        i += 1
      end
    end
    
    return s[0..-4]
  end
  
end

ArduinoRoomOS.new