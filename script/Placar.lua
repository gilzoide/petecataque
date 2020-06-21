largura = WINDOW_WIDTH * 0.8
x = (WINDOW_WIDTH - largura) * 0.5
y = WINDOW_HEIGHT * 0.4
cor = {1, 1, 1}
texto_inicial = [[
PETECATAQUE
Jogue a peteca no chão ou no amiguinho
Use A/D e ←/→ para girar

Aperte Enter para começar
]]
texto_pausado = "Aperte Enter para continuar"
texto_venceu_fmt = "Vitória do jogador %d! =D\nAperte Enter para recomeçar"
ganhador = nil

function draw()
    love.graphics.setColor(cor)
    local texto
    if ganhador then
        texto = string.format(texto_venceu_fmt, ganhador)
    elseif pausado then
        texto = texto_pausado
    else
        texto = texto_inicial
    end
    love.graphics.printf(texto, x, y, largura, 'center')
end

function reset()
    ganhador = nil
end
