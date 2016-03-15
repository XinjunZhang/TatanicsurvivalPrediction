

# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)

shinyUI(fluidPage(sidebarLayout(
  sidebarPanel(
    # use regions as option groups
    textInput("text", label = h3("What is your name?"), value = ""),
    selectizeInput('Sex', 'Sex', choices = list(
      Female=1,Male=0
    ), multiple = F),
    
    # use updateSelectizeInput() to generate options later
    selectizeInput('Marriage', 'Have you married?', choices = list(Yes=1,No=0)),
    selectizeInput('Sib', 'Do you have siblings?', choices = list(Yes=1,No=0)),
    selectizeInput('Children', 'Do you have children?', choices = list(Yes=1,No=0)),
    selectizeInput('Parents', 'Are your parents still alive?', choices = list(Yes=1,No=0)),
    
    numericInput("num1", label = h3("How old are you?"), value = 1),
    
    selectizeInput('Pclass', "What's your annual income?", choices = list(
      "0-200,000"=3,"200,000-400,000"=2,">400,000"=1
    ), multiple = F)
  ),
  mainPanel(
    helpText('If I were on the Tatanic...'),
    imageOutput("preImage"),
    helpText('Output of the infomation in the left:'),
    verbatimTextOutput('values'),
    helpText('The prediction of survival rate for myself:'),
    verbatimTextOutput('prediction')
  )
), title = 'If I were on the Tatanic...'))


