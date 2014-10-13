function validate_ss(ss)
  function split_ss(str)
    return split(str,'[\\/]+')
  end

  if ss and string.match(ss,"[0-9]/[0-9]") then
    local ss_table = split_ss(ss)
    return ss_table[1],ss_table[2]
  else
    error("Tu não sabe digitar uma SS corretamente?")
  end
end

function validate_atividade(atividade)
  if atividade and string.match(atividade,"[0-9]") then
    return atividade
  else
    error("Cara, depois da SS você precisa digitar uma atividade válida. Tipo, 01 (que é programação)")
  end
end

function validate_comentario(comentario)
  if comentario then
    return comentario
  else
    return ""
  end
end
