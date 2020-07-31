- Recursos, instâncias descritas em disco, carregáveis, referenciadas por nome + variante (por exemplo: tamanho da fonte) sem duplicatas
- Receitas são recursos instanciáveis que definem o estado padrão de instâncias (usando `metatable.__index`),
  de modo que mudar a receita muda o padrão de suas instâncias mesmo em runtime (isso facilita hot reload).
  Receitas devem conter o mínimo possível (zero?) de comportamento (funções);
  expressões são bem vindas (para posicionamento relativo, por exemplo)
- Receitas wrapper pra objetos LÖVE, como de física e drawables
- Objetos instanciados, em hierarquia (nested)
- Sistema de tags pra querying da hierarquia, tanto em receita quanto instanciada
- Lint de recursos, principalmente receitas, possivelmente rodando com fswatch ou similar
- Dump e reload de estados (como save states de emuladores) (**CUIDADO** com input press/release no reload)
- Debugger pro estado, read, talvez write
- Sistema de hot reload de recursos enquanto debug
- Comportamentos básicos usando máquina de estados, pattern matching e set
- Warning na tela

+ Compilador pra otimizar o resultado =P
+ Editor gráfico?
