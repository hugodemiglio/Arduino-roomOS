# system("clear")
# print "Enter your name: "
# name = gets
# puts "Hello #{name}"

# loop do
#   time = Time.now.to_s + "\r"
#   print time
#   $stdout.flush
#   sleep 1
# end

class Test
  def secs_to_h secs
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

puts Test.new.secs_to_h 3825