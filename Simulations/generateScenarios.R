methods <- c("crudeMC", "pmc1", "pmc2", "turnipSingle", "turnipFull3", "turnipFull2", "turnipFull1")
scenarios3Levels <- expand.grid(epsilon = c(0.1, 0.01, 0.001, 0.0001), demand = c(1L, 2L, 3L, 4L, 5L), n = 100000L, nCapacities = 3L, graph = "dodecahedron", method = methods, interestVertices = "1,20", stringsAsFactors = FALSE)
scenarios10Levels <- expand.grid(epsilon = c(0.1, 0.01, 0.001, 0.0001), demand = c(1L, 2L, 3L, 28L, 29L, 30L), n = 100000L, nCapacities = 11L, graph = "dodecahedron", method = methods, interestVertices = "1,20", stringsAsFactors = FALSE)
scenarios <- rbind(scenarios3Levels, scenarios10Levels)
scenarios$file <- apply(scenarios, 1, function(x) paste0(as.numeric(x["epsilon"]), "-", as.integer(x["demand"]), "-", as.integer(x["n"]), "-", as.integer(x["nCapacities"]), "-", x["graph"], "-", x["method"], ".RData", sep=""))