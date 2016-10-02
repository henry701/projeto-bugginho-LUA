-- -*- coding: utf-8 -*-

-- Mesmo jeito de declarar file-encoding do que Python? Hm. Legal.

-- Copiado do módulo, porque achei interessante o conceito de manter o máximo das coisas possíveis em uma tabela local, 
-- mesmo esse sendo o arquivo principal do programa.
local _G, table, string, math, tonumber, tostring, type, print = _G, table, string, math, tonumber, tostring, type, print;

print("Hello World!\n\n\n") -- Tem que ter né

-- Meio que uma shim que eu achei, porque as versões novas do Lua depreciaram a keyword module, mas o módulo de validação usa ela.
require "module_shim";

-- Peguei esse módulo de um site arquivado, linguagem assim tem que cavar pra achar...
-- http://web.archive.org/web/20140412004316/http://manoelcampos.com/2011/02/14/validando-cpf-cnpj-em-lua/?wpmp_switcher=mobile
require "valid";

-- Só preferi esse módulo porque tem regex no nome do site, regex é amor, regex é vida.
-- http://regex.info/blog/lua/json
JSON=(loadfile "JSON.lua")();

-- Primeiro as declarações de funções
-- Eta linguagem sofrida que não tem hoisting...

	function tobool(expr)
		return not not expr;
	end

	function string.trim(self)
		return self:match'^()%s*$' and '' or self:match'^%s*(.*%S)'
	end

    function io.flushread(outask, readq)
		local outask = (outask or "");
		local readq = tonumber(readq);
		io.write(outask);
        io.flush();
        return ((readq and io.read(readq)) or io.read());
    end
	
	function io.flushgetchar()
		io.flush();
		return io.getchar();
	end
	
	function io.getchar()
		return io.read(1);
	end
	
	function opcaoInvalida()
		print("Opção inválida!");
		io.flushgetchar();
	end
	
	function ZeroSaiUmFica()
		local res
		repeat
			print("Deseja continuar a operação atual?")
			res = tonumber(io.flushread("0 = Sair || 1 = Continuar: "));
			if res == 0 then
				return false;
			elseif res == 1 then
				return true;
			else
				print("Opção inválida!");
			end
		until false
	end
	
	function pedirNormalizarCPF()
		local cpf, rsp;
		repeat
			cpf = io.flushread("Insira o CPF: ");
			cpf = cpf:gsub("%D", "");
			cpf = string.rep("0", 11-#cpf)..cpf;
			-- Os cara inventa... Pra mim esse operador de diferença parece
			-- um "mais ou menos igual" kkkkkkkkkkkkkkkkkkkkkk
			if valid.cpf(cpf) ~= true then
				print("CPF inválido!");
				rsp = ZeroSaiUmFica();
				if rsp == false then
					return false;
				end
			else
				return cpf;
			end
		until false
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

		-- Cara, como eu amo tabelas de funções. E odeio pcall.
		calltable.menu[((({pcall(math.floor, (resp or -1))})[2]) or -1)]();
		
		-- Tail Recursive, ou será que dá pau depois de umas mexidinhas? :P
		-- EDIT: Vendo os tristes stack traces, constato que SIM,
		-- a linguagem de fato suporta Tail Calling. 
		return menu_principal();
    end
    
    function cadastrar_convidado()
        io.write("======= CADASTRAR CONVIDADO =======\n");
		local cpf, nome, rsp;
		
		repeat
			cpf = pedirNormalizarCPF();
			if cpf == false then
				return false;
			end;
			if TabelaConvidadosProxy[cpf] ~= nil then
				print("CPF já cadastrado!");
				rsp = ZeroSaiUmFica();
				if rsp == false then
					return false;
				end
			else
				break;
			end
		until false
		
		repeat
			nome = io.flushread("Insira o Nome: ");
			if (nome:trim()):len() == 0 then
				print("Nome não pode ser vazio!");
				rsp = ZeroSaiUmFica();
				if rsp == false then
					return false;
				end
			else
				break;
			end
		until false
		
		TabelaConvidadosProxy[cpf] =
		{
			nome = nome,
			motivo = nil
		};
		
		print("\nCONVIDADO FOI CADASTRADO!");
		io.flushgetchar();
		
		return true;	
    end
    
    function consultar_convidado()
		io.write("======== CONSULTAR CONVIDADO ========\n");
        local cpf, convidado, rs;

		repeat
			cpf = pedirNormalizarCPF();
			convidado = TabelaConvidadosProxy[cpf];
			if convidado == nil then
				print("CPF não existente!");
				rsp = ZeroSaiUmFica();
				if rsp == false then
					return;
				end
			else
				break;
			end
		until false
		
		print("\nCONVIDADO ENCONTRADO!");
		print("Nome: " .. convidado.nome);
		-- Esse ternário simulado é um exercício mental divertido, até porque JavaScript
		-- também tem a forma de fazer a mesma coisa. Hoje fiquei o dia todo estudando.
		print("Estado: " .. ((convidado.motivo and "Removido") or "Convidado"));
		-- Uma pena que precisa desse "rs =" aqui por motivos sintáticos, seria um belo ternário...
		rs = (convidado.motivo and (print("Motivo de remoção: " .. convidado.motivo)));
		
		if convidado.motivo == nil then
			repeat
				print("\nDeseja excluir este convidado?");
				rs = io.flushread("[S]im || [N]ão: "):lower();
				if(rs == "s") then
					local motivo = io.flushread("Insira o motivo: ");
					excluir_convidado(cpf, motivo);
					print("\nCONVIDADO EXCLUÍDO!\n");
					break;
				elseif(rs ~= "n") then
					print("Opção Inválida!");
				else
					break;
				end
			until false
		else
			repeat
				print("\nDeseja re-convidar este convidado?");
				rs = io.flushread("[S]im || [N]ão: "):lower();
				if(rs == "s") then
					TabelaConvidadosProxy[cpf].motivo = nil;
					print("\nCONVIDADO RE-CONVIDADO!\n");
					break;
				elseif(rs ~= "n") then
					print("Opção Inválida!");
				else
					break;
				end
			until false
		end
		
		repeat
			print("\nDeseja consultar outro convidado?");
			rs = io.flushread("[S]im || [N]ão: "):lower();
			if(rs == "s") then
				return consultar_convidado();
			end
			if(rs ~= "n") then
				print("Opção Inválida!");
			else
				break;
			end
		until false
		
		return true;
    end
    
    function listar_convidados()
        
		return true;
    end
    
    function listar_removidos()
        
		return true;
    end
	
	function excluir_convidado(cpf, motivo)
		TabelaConvidadosProxy[cpf].motivo = motivo;
		return true;
	end
	
	function sair_prog()
		os.exit();
	end
	
	-- Apagar e regravar o JSON no arquivo
	function GravarArq(tabela)
		ArquivoTabela = io.open("convidados.json", "w");
		ArquivoTabela:write( JSON:encode_pretty( tabela ) );
		ArquivoTabela:close();
		return true;
	end
    

-- Agora configurar pra ficar mais rápido, trocar as funções em si
-- invés de encher o conteúdo delas de IFs pra detectar OS, fazer
-- a(s?) call tables e etc...

	-- God Bless StackOverflow... dá vontade de fazer uma tabela pra esses
	-- valores tb... Switch, cadê switch nessa lang???
	-- God Bless stackoverflow é o caralho, o cara da regex tava muito errado velho.
    local BinaryFormat = package.cpath:match("%.(%a+);");
    if BinaryFormat == "dll" then
    	function os.name()
    		return "Windows"
    	end
    	function io.clearScreen()
    		os.execute("cls")
    	end
    elseif BinaryFormat == "so" then
    	function os.name()
    		return "Linux";
    	end
    	function io.clearScreen()
    		os.execute("clear");
    	end
    elseif BinaryFormat == "dylib" then
    	function os.name()
    		return "MacOS";
    	end
    	function io.clearScreen()
    		os.execute("clear");
    	end
	else
    	function os.name()
    		return "Unknown";
    	end
		function io.clearScreen()
			-- Tava bugando no meu CMD, mas pelo menos limpa a tela né. God bless gambiarra.
			local ws = "";
    		for i=1, 10000, 1 do
				ws = ws .. "\n";
			end;
			io.write(ws);
    	end
    end
    BinaryFormat = nil
    
    -- Tabela de chamadas, porque essa linguagem é rápida mas por algum motivo
    -- NÃO TEM A PORRA DUM SWITCH! Que saudadezinha do meu JS, cara... :(
    calltable =
	{ 
		menu = 
		{
			[1] = cadastrar_convidado,
			[2] = consultar_convidado,
			[3] = listar_convidados,
			[4] = listar_removidos,
			[5] = sair_prog,
		}
	};
	-- Achei em http://www.luafaq.org/gotchas.html essa magic constant, que é tipo
	-- um "default" da tabela, um fallback que invés de retonar Nil, retorna esse valor.
	setmetatable(calltable.menu, { __index = function() return opcaoInvalida end });





-- Global, os dados vão estar sempre na memória e também no arquivo, idealmente mirrored.
ArquivoTabela = nil;

-- Acesso baseado em proxy, uso o valor "TabelaConvidadosProxy" e cada alteração
-- é automaticamente gravada no arquivo, por causa dos metamétodos. Sem precisar
-- copiar e colar a função de atualizar arquivo toda vez que a tabela é alterada. Adorei.
-- Mais detalhes onde eu seto a meta lá no Main!
TabelaConvidadosProxy = { };


-- Já vi gente usando esse padrão, e gostei =)
function main()
	-- Carregar dados do arquivo, se ele existir.
	local TabelaConvidados = {  };
	ArquivoTabela = io.open("convidados.json", "r");
	if ArquivoTabela ~= nil then
		local content = ArquivoTabela:read("*all");
		ArquivoTabela:close();
		TabelaConvidados = (JSON:decode(content) or { });
	end

	-- Aqui está aquilo dos proxies que eu falei.
	-- Essa função recursiva garante que as metatables vão ter acesso a mudanças
	-- de conteúdo nas tabelas filhas também.
	local index_set_listener;
	function index_set_listener(tbl, key, value)
		print("GVRD", tbl, key, value);
		if type(value) == "table" then
			local proxy = { };
			setmetatable(proxy, { __newindex = index_set_listener, __index = value, __pairs = value });
		end
		rawset(tbl, key, value);
		GravarArq(TabelaConvidados);
		return proxy;
	end
	setmetatable(TabelaConvidadosProxy,
	{
		__newindex = index_set_listener,
		__index = TabelaConvidados,
		__tostring = function() return tostring(TabelaConvidados); end,
		__metatable = false, -- |=)|]
		__pairs = TabelaConvidados
	});
	setmetatable(TabelaConvidados,
	{
		__newindex = index_set_listener
	});
	-- Aqui precisamos atribuir ela aos itens que já foram carregados do JSON, 
	-- para isso usamos um loop com pairs.
	for key, value in pairs(TabelaConvidados) do
		if type(value) == "table" then
			setmetatable(value, { __newindex = index_set_listener });
		end
	end

    menu_principal();
end
-- E cabou!
main();