local _G, table, string, math, tonumber, tostring, type, print = _G, table, string, math, tonumber, tostring, type, print

---Módulo para validação de dados
--@author Manoel Campos da Silva Filho - http://manoelcampos.com
--@version 0.2
module "valid"

---Divide uma string utilizando um determinado separador existente nela.
--Fonte: http://lua-users.org/wiki/SplitJoin
--@param self String a ser dividida
--@param sep Separador a ser utilizado para dividir a string
--@return Retorna uma tabela com as strings divididas
function string.split(self, sep)
  local sep, fields = sep or ":", {}
  local pattern = string.format("([^%s]+)", sep)
  self:gsub(pattern, function(c) fields[#fields+1] = c end)
  return fields
end

---Verifica se um CPF é válido.
--Adaptado de http://www.linhadecodigo.com.br/dica/1080/Script-simples-de-valida%C3%A7%C3%A3o-de-CPF.aspx
--Contribuições de Tomas Guisasola Gorham
--@author Manoel Campos da Silva Filho - http://manoelcampos.com
--@param value String contendo o CPF a ser validado
--@return Retorna true caso o CPF seja válido, e false caso contrário.
function cpf(value) 
  if type(value) ~= "string" then
     value = tostring(value)
  end
  value = value:gsub("%D", "")
  value = string.rep("0", 11-#value)..value
  
  local numero = value:sub(1, 9)
  local dv = 0
    
  for i, d in numero:gmatch("()(.)") do
     dv = dv + tonumber(d) * (11-i)
  end

  if (dv == 0) then
    return false 
  end
    
  dv = 11 - math.fmod(dv, 11) 
    
  if (dv > 9) then
     dv = 0
  end
  
  --Se o primeiro caractere do DV for diferente do valor calculado, o CPF é inválido
  if (value:sub(10, 10) ~= tostring(dv)) then 
    return false
  end
    
  dv = dv * 2
    
  for i, d in numero:gmatch("()(.)") do
    dv = dv + tonumber(d) * (12-i) 
  end
    
  dv = 11 - math.fmod(dv, 11)
    
  if (dv > 9) then
     dv = 0
  end
    
  --Se o segundo caractere do DV for igual ao valor calculado o CPF é válido
  return value:sub(11) == tostring(dv) 
end

---Verifica se um CNPJ é válido.
--Adaptado de http://www.pcforum.com.br/cgi/yabb/YaBB.cgi?num=1090001360
--@author Manoel Campos da Silva Filho - http://manoelcampos.com
--@param value String contendo o CNPJ a ser validado
--@return Retorna true caso o CNPJ seja válido, e false caso contrário.
function cnpj(value)
  if type(value) ~= "string" then
     value = tostring(value)
  end
  value = value:gsub("%D", "")
  value = string.rep("0", 14-#value)..value
  
  --Verifica se todos os dígitos são iguais ao primeiro (assim, todos são iguais e o CNPJ é inválido)
  local iguais = true
  for i, d in value:gmatch("()(.)") do
      if value:sub(1,1) ~= d then
         iguais = false
      end
  end
  
  if iguais then
     return false
  end
  
  local numeros = value:sub(1, 12)
  local soma = 0
  local pos = #numeros - 7
  for i, d in numeros:gmatch("()(.)")  do
      soma = soma + tonumber(d) * pos
      pos = pos - 1
      if pos < 2 then
         pos = 9
      end
  end

  local dv = 0
  if math.fmod(soma, 11) >= 2 then
     dv = 11 - math.fmod(soma, 11)
  end
  
  --Se o primeiro caractere do DV for diferente do valor calculado, o CNPJ é inválido
  if value:sub(13, 13) ~= tostring(dv) then
     return false
  end
  
  local tamanho = #numeros + 1
  numeros = value:sub(1, tamanho)
  pos = tamanho - 7
  soma = 0
  for i, d in numeros:gmatch("()(.)")  do
      soma = soma + tonumber(d) * pos
      pos = pos - 1
      if pos < 2 then
         pos = 9
      end
  end

  if math.fmod(soma, 11) < 2 then
     dv = 0
  else
     dv = 11 - math.fmod(soma, 11)
  end
  
  --Se o segundo caractere do DV for igual ao valor calculado, o CNPJ é válido
  return value:sub(14) == tostring(dv)
end

---Verifica se uma data no formato dd/mm/yyyy é válida
--@author Manoel Campos da Silva Filho - http://manoelcampos.com
--@param value String contendo a data a ser validata
--@return Retorna true se a data for válida e false caso contrário
function date(value)
  if value == nil then
     return false
  end
  --Indica a quantidade de dias em cada mês do ano
  local dias_mes = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31}

  local fields = value:split("/")
  
  if #fields ~= 3 then
     return false
  end  
  local dia, mes, ano = tonumber(fields[1]) or 0, tonumber(fields[2]) or 0, tonumber(fields[3]) or 0
  if math.fmod(ano, 4) == 0 then
     dias_mes[2] = 29
  end
  
  return (dia >= 1 and dia <= dias_mes[mes]) and (mes >=1 and mes <= 12) and (ano > 0)
end

---Verifica se uma hora no formato hh:nn, hh:nn:ss ou hh:nn:ss:zzz é válida
--onde hh é a hora, nn são os minutos, ss são os segundos e zzz são os milisegundos
--@author Manoel Campos da Silva Filho - http://manoelcampos.com
--@param value String contendo a data a ser validata
--@return Retorna true se a data for válida e false caso contrário
function time(value)
  if value == nil then
     return false
  end
  local fields = value:split(":")
  
  if #fields < 2 then
     return false
  end  
  local hora, min, seg, miliseg = tonumber(fields[1]) or 0, tonumber(fields[2]) or 0, tonumber(fields[3]) or 0, tonumber(fields[4]) or 0
  return (hora >= 0 and hora <= 23) and (min >= 0 and min <= 59) and (seg >= 0 and seg <= 59) and (miliseg >= 0 and miliseg <= 999)
end

