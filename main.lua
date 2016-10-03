-- -*- coding: utf-8 -*-

-- Mesmo jeito de declarar file-encoding do que Python? Hm. Legal.

-- Copiado do módulo, porque achei interessante o conceito de manter o máximo das coisas possíveis em uma tabela local, 
-- mesmo esse sendo o arquivo principal do programa. Fora que boatos que aumenta a eficiência também.
local _G, table, string, math, tonumber, tostring, type, print = _G, table, string, math, tonumber, tostring, type, print;

print("Hello World!"); -- Tem que ter né

-- Foi uma das últimas coisas que eu achei, eta beleza!
os.setlocale('pt_BR');

-- http://stackoverflow.com/questions/5243179/what-is-the-neatest-way-to-split-out-a-path-name-into-its-components-in-lua
-- YEEEEEEEEEEHAAAAAAAAA
CURRENT_PATH = (string.match(arg[0], "(.-)([^\\/]-%.?([^%.\\/]*))$"));

CAMINHO_CONVIDADOS = CURRENT_PATH .. "convidados.json";

-- Meio que uma shim que eu achei, porque as versões novas do Lua depreciaram a keyword module, mas o módulo de validação usa ela.
require "./includes/module_shim";

-- Peguei esse módulo de um site arquivado, linguagem assim tem que cavar pra achar...
-- http://web.archive.org/web/20140412004316/http://manoelcampos.com/2011/02/14/validando-cpf-cnpj-em-lua/?wpmp_switcher=mobile
require "./includes/valid";


-- Esse deu um rolezinho de fazer, hein!
require "./includes/encapsulate";


-- Só preferi esse módulo porque tem regex no nome do site, regex é amor, regex é vida.
-- http://regex.info/blog/lua/json
JSON = (loadfile(CURRENT_PATH .. "includes/JSON.lua"))();


-- Primeiro as declarações de funções
-- Eta linguagem sofrida que não tem hoisting...

	function tobool(expr)
		return not not expr;
	end

	function string.trim(self)
		return self:match'^()%s*$' and '' or self:match'^%s*(.*%S)';
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
		local res;
		repeat
			print("Deseja continuar a operação atual?");
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
		
    	print("================ MENU PRINCIPAL ================");
    	print("1 - Cadastrar Convidados");
    	print("2 - Consultar Convidado por CPF");
    	print("3 - Listar Convidados");
    	print("4 - Listar Removidos");
		print("5 - Sair do Programa");
    	print("================================================");
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
        print("============ CADASTRAR CONVIDADO ============\n");
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
		
		repeat
			print("\nDeseja cadastrar outro convidado?");
			rs = io.flushread("[S]im || [N]ão: "):lower();
			if(rs == "s") then
				io.clearScreen();
				return cadastrar_convidado();
			end
			if(rs ~= "n") then
				print("Opção Inválida!");
			else
				break;
			end
		until false
		
		return true;	
    end
    
    function consultar_convidado()
		print("============= CONSULTAR CONVIDADO =============\n");
        local cpf, convidado, rs;

		repeat
			cpf = pedirNormalizarCPF();
			convidado = TabelaConvidadosProxy[cpf];
			if convidado == nil then
				print("CPF não existente!");
				rsp = ZeroSaiUmFica();
				if rsp == false then
					io.clearScreen();
					return;
				end
			else
				break;
			end
		until false
		
		print("\nCONVIDADO ENCONTRADO!");
		print("Nome: " .. convidado.nome);
		print("CPF: " .. MascaraCPF(cpf));
		-- Esse ternário simulado é um exercício mental divertido, até porque JavaScript
		-- também tem a forma de fazer a mesma coisa. Hoje fiquei o dia todo estudando.
		print("Estado: " .. ((convidado.motivo and convidado.motivo ~= "" and "Removido") or "Convidado"));
		-- Uma pena que precisa desse "rs =" aqui por motivos sintáticos, seria um belo ternário...
		rs = (convidado.motivo and convidado.motivo ~= "" and (print("Motivo de remoção: " .. convidado.motivo)));
		
		if convidado.motivo == nil or convidado.motivo == "" then
			repeat
				print("\nDeseja excluir este convidado?");
				rs = io.flushread("[S]im || [N]ão: "):lower();
				if(rs == "s") then
					local motivo = io.flushread("\nInsira o motivo: ");
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
					TabelaConvidadosProxy[cpf].motivo = "";
					print("\nCONVIDADO RE-CONVIDADO!");
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
				io.clearScreen();
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
		print("========== LISTA DE CONVIDADOS ==========\n");
        for key, value in pairs(TabelaConvidadosProxy) do
			if value.motivo == nil or value.motivo == "" then
				print("Nome: " .. value.nome);
				print("CPF:  " .. MascaraCPF(key) .. "\n");
			end
		end
		print("\n============= FIM DA LISTA ==============\n");
		io.flushgetchar();
		return true;
    end
    
    function listar_removidos()
		print("===== LISTA DE CONVIDADOS REMOVIDOS =====\n");
        for key, value in pairs(TabelaConvidadosProxy) do
			if value.motivo ~= nil and value.motivo ~= "" then
				print("Nome:   " .. value.nome);
				print("CPF:    " .. MascaraCPF(key));
				print("Motivo: " .. value.motivo .. "\n");
			end
		end
		print("============= FIM DA LISTA ==============\n");
		io.flushgetchar();
		return true;
    end
	
	function excluir_convidado(cpf, motivo)
		TabelaConvidadosProxy[cpf].motivo = motivo;
		return true;
	end
	
	function sair_prog()
		os.exit();
	end
	
	function MascaraCPF(cpf)
		local cpf = tostring(cpf);
		cpf = cpf:gsub("%D", "");
		cpf = string.rep("0", 11-#cpf)..cpf;
		cpf = cpf:sub(1, 3) .. "." .. cpf:sub(4, 6) .. "." .. cpf:sub(7, 9) .. "-" .. cpf:sub(10, 11);
		return cpf;
	end
	
	-- Apagar e regravar o JSON no arquivo
	function GravarArq(tabela)
		ArquivoTabela = io.open(CAMINHO_CONVIDADOS, "w");
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
	ArquivoTabela = io.open(CAMINHO_CONVIDADOS, "r");
	if ArquivoTabela ~= nil then
		local content = ArquivoTabela:read("*all");
		ArquivoTabela:close();
		TabelaConvidados = (JSON:decode(content) or { });
	end

	-- Aqui está aquilo dos proxies que eu falei. Ficou tão grande que transformei
	-- em outro arquivo essa caralha. Mas dá uma boa biblioteca de encapsulamento ;)
	local function hook(proxy, tbl, key, value, ValorReal)
		GravarArq(TabelaConvidados);
	end
	TabelaConvidadosProxy = encapsulate.WatchTable(TabelaConvidados, hook);

    menu_principal();
end
-- E cabou!
main();