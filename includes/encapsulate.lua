-- -*- coding: utf-8 -*-

-- Módulo feito por mim mesmo pra aprender LUA. Gostei da metaprogramação, história e performance da linguagem.
-- Esse módulo permite adicionar um hook em uma tabela para escutar QUALQUER MUDANÇA de índices de tabelas,
-- sejam elas tabelas filhas ou a tabela em que o hook foi adicionado em si.

encapsulate = {  };

-- Encapsulamento e proteção preguiçosa mas eficiente das nossas variáveis, incluindo a global :P
local _G, table, string, math, tonumber, tostring, type, print = _G, table, string, math, tonumber, tostring, type, print;

-- Aqui está aquilo dos proxies que eu falei.
-- Essa função recursiva garante que as metatables vão ter acesso a mudanças
-- de conteúdo nas tabelas filhas também.
local function index_set_listener(proxy, tbl, key, value, hook)
	local ValorReal;
	if type(value) == "table" then
		-- Se o valor gravado for uma tabela, substui ela por OUTRA TABELA PROXY pra poder acoplar os
		-- hooks nela, e setta o valor que foi passado como ESSA NOVA tabela, que está no
		-- NOSSO escopo! Muahahahaha.
		local proxy_son = encapsulate.WatchTable(value, hook);
		ValorReal = proxy_son;
	else
		ValorReal = value;
	end
	rawset(tbl, key, ValorReal);
	-- Chama o hook depois dessa alteração.
	hook(proxy, tbl, key, value, ValorReal, tbl_assgn);
end

-- Aqui é a função pra observar tabelas com determinado hook, recursivamente. Coloca o nosso hook,
-- depois passa pro hook to usuário. Essa é a exportada.
function encapsulate.WatchTable(tbl, hook)
	local proxy = { };
	setmetatable(proxy,
	{
		__index = tbl, -- A busca sempre retorna a tabela real
		__metatable = false, -- Metatable imodificável
		__newindex = function(proxy, key, value) -- Newindex é hookado com a função abaixo
			index_set_listener(proxy, tbl, key, value, hook);
		end,
		__pairs = function (t)
			local custom_next = function(tb, ky)
				return next(tbl, ky); -- Next customizado que aponta para a tabela real
			end
			return custom_next, t, nil;
		end
	});
	-- Se tiver tabelas de filho, já sabe né? ;)
	for key, value in pairs(tbl) do
		if type(value) == "table" then
			rawset(tbl, key, encapsulate.WatchTable(value, hook));
		end
	end
	return proxy;
end