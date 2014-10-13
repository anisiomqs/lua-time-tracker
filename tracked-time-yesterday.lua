local luasql = require "luasql.oci8"
local env = luasql.oci8()
local conn = env:connect("sa","sa","oracle")

local responsaveis = {}

for i = 1, #arg do
  responsaveis[#responsaveis + 1] = arg[i]
end

for i = 1, #responsaveis do
  local resp = responsaveis[i]

  local cur = conn:execute(string.format([[
    select nvl(sum(a.tempo_gasto),0) tempo
    from horas_trab a
    where trunc(a.data_atividade) = decode(trim(to_char(sysdate,'DAY')),'MONDAY',trunc(sysdate-3),trunc(sysdate-1))
    and   a.cod_responsavel = %s
  ]],resp))

  local row = cur:fetch({},"a")

  while row do
    print(resp .. ": " .. row.tempo .. "h")
    row = cur:fetch(row,"a")
  end

  cur:close()
end

conn:close()
env:close()
