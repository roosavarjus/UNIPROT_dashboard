### FUTRE IMPROVEMENTS ###
# [ ] tab for plotting

library(shiny)
library(bslib)
library(writexl)
library(DT)
library(UniprotR)

# source("preprocess.R")

theme_uniprot <- bs_theme(
    version = 4,
    bootswatch = "minty",
    bg = "#E7E7E7",
    fg = "#000",
    primary = "#004A5B",
    secondary = "#51A1B4",
    success = "#00DBFF",
    info = "#51A1B4"
)

### UI ###
#___________________________________________________________
ui <- navbarPage(
    title = "Dashboard for Uniprot ID parsing",
    theme = theme_uniprot,
    
    ## TAB 1: Import data
    tabPanel("Import data",
             # input uniprot IDs
             textAreaInput("codes",
                           "Copy Uniprot IDs here separated by newline (enter)",
                           value = "A2BC19\nP12345\nP31946\nP62258",
                           width = 700,
                           height = 70),
             actionButton("apply", "Import")
             ),
    
    ## TAB 2: Parse data
    tabPanel("Data table",
             sidebarLayout(
                 sidebarPanel("Choose features to display:",
                              checkboxGroupInput(inputId = "features",
                                          label = " ",
                                          choices = c("Cofactor", "GO function")),
                              hr(),
                              helpText("Download displayed table"),
                              hr(),
                              textInput("name_table",
                                        NULL,
                                        value = "table.xlsx",
                                        placeholder = "table.xlsx"),
                              downloadButton("save_table",
                                             label = "Download",
                                             outputId = "savet_table"),
                              hr(),
                              helpText("Created by Roosa Varjus"),
                              helpText("(dbn257@alumni.ku.dk)")
                              ),
                 mainPanel(
                     dataTableOutput(outputId = "table")
                 )
             )),
    tabPanel("Plots",
             sidebarLayout(
                 sidebarPanel("Choose what to plot:",
                              radioButtons(inputId = "plots",
                                           label = " ",
                                           choices= c("lol", "lel")
                                           # choices = c("GO molecular" = go(),
                                           #             "GO subcellular" = go(),
                                           #             "GO biological" = go(),
                                           #             "GO info" = go(),
                                                        )),
                 mainPanel("moi")
             ))
    
    
    
)

### SERVER ###
#___________________________________________________________
server <- function(input, output) {
    id_list <- reactive({as.vector(strsplit(input$codes, "\n")[[1]])})
    observeEvent(input$apply,{
                 showModal(modalDialog(
                     title = "Done!", 
                     "It takes a short while for the datatable to show...",
                     easyClose = T))})
    
    gene_names   <- reactive({ConvertID(id_list(), ID_from = "ACC+ID", ID_to = "GENENAME")})
    functions    <- reactive({GetProteinFunction(id_list())})
    go           <- reactive({GetProteinGOInfo(id_list())}) # save ChEBI..Cofactor., Function..CC., Pathway
    subcellular  <- reactive({GetSubcellular_location(id_list())})
    output$table <- renderDataTable(data.frame(id_list(), gene_names(), functions(), go(), subcellular()))
    
    
}







### RUN ###
#___________________________________________________________
# Run the application 
shinyApp(ui = ui, server = server)
