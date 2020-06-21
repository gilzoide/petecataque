cor = {1, 0, 0}
cor_fundo = {0, 0, 0}
cor_borda = {1, 1, 1}
cor_dano = {1, 0, 0}
largura = WINDOW_WIDTH * 0.4
altura = 15
segundos_pra_acabar = 0.5
acabou = false

function init()
    -- alignment = flipX and 'right' or 'left'
    local margin = 10
    x = flipX and WINDOW_WIDTH - largura - margin or margin
    y = 10
    reset()
end

function reset()
    segundos_faltando = segundos_pra_acabar
    acabou = false
end

function draw()
    love.graphics.setColor(cor_fundo)
    love.graphics.rectangle('fill', x, y, largura, altura)
    
    local porcentagem = segundos_faltando / segundos_pra_acabar
    love.graphics.setColor(tomou_dano and cor_dano or cor)
    local x_advance = flipX and largura * (1 - porcentagem) or 0
    local largura_proporcional = largura * porcentagem
    love.graphics.rectangle('fill', x + x_advance, y, largura_proporcional, altura)
    
    love.graphics.setColor(cor_borda)
    love.graphics.rectangle('line', x, y, largura, altura)

    tomou_dano = false
end

function toma_dano()
    segundos_faltando = math.max(0, segundos_faltando - dt)
    acabou = segundos_faltando <= 0
    tomou_dano = true
end
