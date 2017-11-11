library(rly)

TOKENS = c('WORD', 'OTHER')
LITERALS = c('=','+','-','*','/', '(',')')

Lexer <- R6::R6Class("Lexer",
  public = list(
    tokens = TOKENS,
    literals = LITERALS,
    t_WORD = function(re='(?i)[a-z0-9]+', t) {
      return(t)  
    },
    t_OTHER = function(re='.', t) {
      return(t)
    },
    t_ignore = " \t",
    t_newline = function(re='\\n+', t) {
      t$lexer$lineno <- t$lexer$lineno + nchar(t$value)
      return(NULL)
    },
    t_error = function(t) {
      cat(sprintf("Illegal character '%s'", t$value[1]))
      t$lexer$skip(1)
      return(t)
    }
  )
)

lexer  <- rly::lex(Lexer)

lexer$input('this is a TEST, possibly a simplistic test, but not a SIMPLE test because it contains : 2,2-bis(4-hydroxy-3-tert-butylphenyl)propane and 2,2-bis(4-tert-3-hydroxy-butylphenyl)propane amongst other things')

while (lexer$lexpos <= lexer$lexlen) {
  print(lexer$token())
}

lexer$input('this is a TEST, possibly a simplistic test, but not a SIMPLE test because it contains:\n2,2-bis(4-hydroxy-3-tert-butylphenyl)propane and 2,2-bis(4-tert-3-hydroxy-butylphenyl)propane amongst other things')

while (lexer$lexpos <= lexer$lexlen) {
  tok <- lexer$token()
  print(tok$type)
  print(tok$value)
  print(tok$lexpos)
  print(tok)
}
