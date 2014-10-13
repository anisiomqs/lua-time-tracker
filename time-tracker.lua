dofile("util.lua")
dofile("validations.lua")
dofile("config.lua")

luasql = require "luasql.oci8"
env = luasql.oci8()
conn = env:connect(db.user,db.instance,db.passwd)

function parse_args(args)
  local op = string.lower(arg[1])
  if op == "start" then
    local sol, seq = validate_ss(arg[2])
    local atividade = validate_atividade(arg[3])
    local comentario = validate_comentario(arg[4])

    start(sol,seq,atividade,comentario)
  elseif op == "stop" then
  elseif op == "status" then
  else
    print([[
      Colabore comigo. Você precisa seguir a sintaxe:
      $ lua time-tracker {start,stop,status} [parâmetros]
      start: usado para iniciar lançamento de hora em SS.
             Deve passar os parâmetros: SS/Seq Atividade "Comentário"
             $ lua time-tracker start 66666/666 01 "Programando rede neural no Vision."
       stop: não precisa passar nada. Vai parar o lançamento de horas aberto.
     status: não precisa passar nada. Vai listar a SS que você está trabalhando.
    ]])
  end
end

function start(sol, seq, atividade, comentario)
  finish_open_track(sol, seq, atividade, comentario)
  local res = assert(conn:execute(string.format([[
    insert into horas_dia
    (solicitacao,
     sequencia,
     tipo_atividade,
     data_atividade,
     responsavel,
     inicio,
     termino,
     faturar,
     descricao,
     tempo_gasto,
     sequencia_dia,
     sequencia_ativ,
     sequencia_horas,
     codigo_cliente)
    values
    (%s,
     %s,
     %s,
     sysdate,
     %s,
     sysdate,
     null,
     0,
     %s,
     0,
     %s,
     0
     )
  ]],sol,seq,atividade,codigo_usuario,comentario)))
end

function finish_open_track(sol,seq,atividade,comentario)
  open_track = get_open_track()
  if open_track then
    local sequencia_atividade = get_sequencia_atividade(sol,seq)
    local sequencia_hora = get_sequencia_hora(sol,seq,sequencia_atividade)

    local res = assert(conn:execute(string.format([[
      insert into atividades
      (cod_solicitacao,         sequencia_sol,
       sequencia_ativ,          tipo_atividade,
       descricao)
      VALUES
      (%s,                      %s,
       %s,                      %s,
       %s)
    ]]),sol,seq,sequencia_atividade,tipo_atividade,comentario))

    local res = assert(conn:execute(string.format([[
      insert into horas_trab
      (cod_solicitacao,         sequencia_sol,
       sequencia_ativ,          sequencia_horas,
       data_atividade,          cod_responsavel,
       hora_inicio,             hora_final,
       tempo_gasto,             faturar)
      VALUES
      (%s,                      %s,
       %s,                      %s,
       sysdate,                 %s,
       %s,                      sysdate,
       (sysdate - %s) / 24,     0)
    ]]),sol,seq,sequencia_atividade,sequencia_hora,codigo_usuario,open_track.inicio))
  end
end

function get_open_track()
  local cur = conn:execute(string.format([[
    select horas_dia.solicitacao,            horas_dia.sequencia,
           horas_dia.tipo_atividade,         to_char(horas_dia.data_atividade, 'YYYY-MM-DD HH24:MI:SS') data_atividade,
           horas_dia.responsavel,            to_char(horas_dia.inicio, 'YYYY-MM-DD HH24:MI:SS') inicio,
           horas_dia.faturar,
           horas_dia.descricao,              horas_dia.sequencia_dia
    from horas_dia
    where trunc(data_atividade) = trunc(sysdate)
      and responsavel    = %s
      and termino       is null
    order by sequencia_dia desc
  ]],codigo_usuario))

  local row = cur:fetch({},"a")
  cur:close()

  if row then
    return row
  else
    return nil
  end
end

function get_sequencia_atividade(sol,seq)
  local cur = conn:execute(string.format([[
    select nvl(max(sequencia_ativ),0) + 1 sequencia from atividades
    where cod_solicitacao = %s
      and sequencia_sol   = %s;
  ]],sol,seq))

  local row = cur:fetch({},"a")
  cur:close()

  if row then
    return row.sequencia
  else
    return nil
  end
end


function get_sequencia_hora(sol,seq,sequencia_atividade)
  local cur = conn:execute(string.format([[
    select nvl(max(sequencia_horas),0) + 1 sequencia from horas_trab
    where cod_solicitacao = %s
      and sequencia_sol   = %s
      and sequencia_ativ  = %s;
  ]],sol,seq,sequencia_atividade))

  local row = cur:fetch({},"a")
  cur:close()

  if row then
    return row.sequencia
  else
    return nil
  end
end

parse_args(arg)



-- for i = 1, #arg do
--   responsaveis[#responsaveis + 1] = arg[i]
-- end
--
-- for i = 1, #responsaveis do
--   local resp = responsaveis[i]
--
--   local cur = conn:execute(string.format([[
--     select nvl(sum(a.tempo_gasto),0) tempo
--     from horas_trab a
--     where trunc(a.data_atividade) = decode(trim(to_char(sysdate,'DAY')),'MONDAY',trunc(sysdate-3),trunc(sysdate-1))
--     and   a.cod_responsavel = %s
--   ]],resp))
--
--   local row = cur:fetch({},"a")
--
--   while row do
--     print(resp .. ": " .. row.tempo .. "h")
--     row = cur:fetch(row,"a")
--   end
--
--   cur:close()
-- end
--
-- conn:close()
-- env:close()
