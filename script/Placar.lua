largura = WINDOW_WIDTH * 0.8
x = (WINDOW_WIDTH - largura) * 0.5
y = WINDOW_HEIGHT * 0.5
cor = {1, 1, 1}
texto_esperando = "Aperte Enter para começar"
texto_venceu_fmt = "Vitória do jogador %d! =D\nAperte Enter para recomeçar"

function draw()
    love.graphics.setColor(cor)
    local texto = ganhador and string.format(texto_venceu_fmt, ganhador) or texto_esperando
    love.graphics.printf(texto, x, y, largura, 'center')
end

function reset()
    ganhador = nil
end
