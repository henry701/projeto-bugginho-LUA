-- -*- coding: utf-8 -*-

-- Mesmo jeito de declarar file-encoding do que Python? Hm. Legal.

-- Copiado do módulo, porque achei interessante o conceito de manter o máximo das coisas possíveis em uma tabela local, 
-- mesmo esse sendo o arquivo principal do programa.
local _G, table, string, math, tonumber, tostring, type, print = _G, table, string, math, tonumber, tostring, type, print;

print("Hello World!\n\n\n") -- Tem que ter né

-- Peguei esse módulo de um site arquivado, linguagem assim tem que cavar pra achar...
-- http://web.archive.org/web/20140412004316/http://manoelcampos.com/2011/02/14/validando-cpf-cnpj-em-lua/?wpmp_switcher=mobile
require "valid";

-- Só preferi esse módulo porque tem regex no nome do site, regex é amor, regex é vida.
-- http://regex.info/blog/lua/json
JSON=(loadfile "JSON.lua")();

-- Primeiro as declarações de funções
-- Eta linguagem sofrida que não tem hoisting...

	function string.trim(self)
		return self:match'^()%s*$' and '' or self:match'^%s*(.*%S)'
	end

    function io.flushread(outask)
		local outask = (outask and outask .. "\n" or nil) or ""
		io.write(tostring(outask));
        io.flush();
        return io.read();
    end
	
	function opcaoInvalida()
		print("Opção inválida!");
		io.flushread();
	end
    
    function menu_principal()
		io.clearScreen();
		
    	print("========= MENU PRINCIPAL =========");
    	print("1 - Cadastrar Convidados");
    	print("2 - Consultar Convidado por CPF");
    	print("3 - Listar Convidados");
    	print("4 - Listar Removidos");
		print("5 - Sair do Programa");
    	print("==================================");
		print();
    	io.write("Insira sua opção: ");
    	
    	local resp = tonumber(io.flushread(), 10);
    	io.clearScreen();

		-- Cara, como eu amo tabelas de funções.
		pcall(calltable.menu[math.floor(resp)]);

		-- Tail Recursive, ou será que dá pau depois de umas mexidinhas? :P
		return menu_principal();
    end
    
    function cadastrar_convidado()
        io.write("======= CADASTRAR CONVIDADO =======\n");
		repeat
			local cpf = io.flushread("Insira o CPF: ");
			cpf = value:gsub("%D", "")
			cpf = string.rep("0", 11-#value)..value
			-- Os cara inventa... Pra mim esse operador de diferença parece
			-- um "mais ou menos igual" kkkkkkkkkkkkkkkkkkkkkk
			if valid.cpf(cpf) ~= true then
				print("CPF inválido!");
			elseif TabelaConvidados[cpf] ~= nil then
			    print("CPF já cadastrado!");
			else
				break;
			end
		until false
		repeat
			local nome = io.flushread("Insira o Nome: ");
			if (nome:trim()):len() == 0 then
				print("Nome não pode ser vazio!");
			else
				break;
			end
		until false
		TabelaConvidados[cpf] = { };
		TabelaConvidados[cpf].nome = nome;
		TabelaConvidados[cpf].motivo = nil;
    end
    
    function consultar_convidado()
        
    end
    
    function listar_convidados()
        
    end
    
    function listar_removidos()
        
    end
	
	function sair_prog()
		gravar_arq();
		exit();
	end
	
	function gravar_arq()
		return ArquivoTabela:write( JSON:encode_pretty( TabelaConvidados ) );
	end
    

-- Agora configurar pra ficar mais rápido, trocar as funções em si
-- invés de encher o conteúdo delas de IFs pra detectar OS, fazer
-- a(s?) call tables e etc...

	-- God Bless StackOverflow
    local BinaryFormat = package.cpath:match("%p[\\|/]?%p(%a+)")
    if BinaryFormat == "dll" then
    	function os.name()
    		return "Windows"
    	end
    	function io.clearScreen()
    		os.execute("cls")
    	end
    elseif BinaryFormat == "so" then
    	function os.name()
    		return "Linux"
    	end
    	function io.clearScreen()
    		os.execute("clear")
    	end
    elseif BinaryFormat == "dylib" then
    	function os.name()
    		return "MacOS"
    	end
    	function io.clearScreen()
    		os.execute("clear")
    	end
    end
    BinaryFormat = nil
    
    -- Tabela de chamadas, porque essa linguagem é rápida mas por algum motivo
    -- NÃO TEM A PORRA DUM SWITCH! E literais de objeto só são permitidas
	-- em uma linha aqui, que saudadezinha do meu JS, cara... :(
    calltable = { };
    calltable.menu = { };
    calltable.menu[1] = cadastrar_convidado;
    calltable.menu[2] = consultar_convidado;
    calltable.menu[3] = listar_convidados;
    calltable.menu[4] = listar_removidos;
	calltable.menu[5] = sair_prog;
	-- Achei em http://www.luafaq.org/gotchas.html essa magic constant, que é tipo
	-- um "default" da tabela, um fallback que invés de retonar Nil, retorna esse valor.
	calltable.__index = opcaoInvalida;





-- Global, os dados vão estar sempre na memória e também no arquivo, idealmente mirrored.
TabelaConvidados = { };
ArquivoTabela = nil;

-- Já vi gente usando esse padrão, e gostei =)
function main()
	-- Carregar dados do arquivo, se ele existir.
	ArquivoTabela = io.open("convidados.json", "r")
	if ArquivoTabela ~= nil then
	    local content = ArquivoTabela:read("*all")
        ArquivoTabela:close()
        TabelaConvidados = JSON:decode(content);
    end
	ArquivoTabela = io.open("convidados.json", "w");
    menu_principal();
end
-- E cabou!
main();