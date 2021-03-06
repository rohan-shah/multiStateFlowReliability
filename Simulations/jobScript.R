source("./generateScenarios.R")
SCENARIO_INDEX <- as.integer(Sys.getenv("SCENARIO_INDEX"))


outputFile <- file.path("results", scenarios[SCENARIO_INDEX, "file"])
tmpFile <- paste0(outputFile, ".tmp")
library(multiStateFlowReliability)
library(stringr)
library(igraph)

epsilon <- scenarios[SCENARIO_INDEX, "epsilon"]
method <- scenarios[SCENARIO_INDEX, "method"]
demand <- scenarios[SCENARIO_INDEX, "demand"]
n <- scenarios[SCENARIO_INDEX, "n"]
graph <- scenarios[SCENARIO_INDEX, "graph"]
nReps <- scenarios[SCENARIO_INDEX, "nReps"]

cat("SCENARIO_INDEX=", SCENARIO_INDEX, "\n", sep="")
cat("method=", method, "\n", sep="")

getCapacityMatrix <- function(rho, bi, epsilon)
{
	capacityMatrix <- data.frame(capacity = 0:bi, probability = rho^(bi - (0:bi) - 1)*epsilon)
	capacityMatrix[bi+1,"probability"] <- 1 - sum(capacityMatrix[1:(bi),"probability"])
	return(capacityMatrix)
}

interestVertices <- as.integer(str_split(scenarios[SCENARIO_INDEX, "interestVertices"], ",")[[1]])

if(graph == "dodecahedron5EqualCapacity")
{
	graph <- igraph::read.graph("./dodecahedron.graphml", format = "graphml")
	capacityMatrix <- getCapacityMatrix(rho = 0.7, epsilon = epsilon, bi = 4)
	capacityList <- replicate(30, capacityMatrix, simplify=FALSE)

	maxCapacity <- max(capacityMatrix[,1])
} else if(graph == "dodecahedron15UnequalCapacity")
{
	graph <- igraph::read.graph("./dodecahedron.graphml", format = "graphml")
	capacityMatrix1 <- getCapacityMatrix(rho = 0.7, epsilon = epsilon, bi = 10)
	capacityMatrix2 <- getCapacityMatrix(rho = 0.7, epsilon = epsilon, bi = 15)
	capacityList <- replicate(30, capacityMatrix1, simplify=FALSE)

	#Work out which edges should have the second capacity distribution
	edgeMatrix <- igraph::get.edges(graph, igraph::E(graph))
	secondCapacityEdges <- which(edgeMatrix[,1] %in% c(1, 20) | edgeMatrix[,2] %in% c(1, 20))
	capacityList[secondCapacityEdges] <- replicate(length(secondCapacityEdges), capacityMatrix2, simplify=FALSE)
} else if(graph == "grid10x10_1")
{
	graph <- igraph::make_lattice(dimvector = c(10,10))
	capacityMatrix1 <- getCapacityMatrix(rho = 0.6, epsilon = epsilon, bi = 8)
	capacityList <- replicate(180, capacityMatrix1, simplify=FALSE)
} else if(graph == "grid6x6_1")
{
	graph <- igraph::make_lattice(dimvector = c(6,6))
	capacityMatrix1 <- getCapacityMatrix(rho = 0.6, epsilon = epsilon, bi = 8)
	capacityList <- replicate(60, capacityMatrix1, simplify=FALSE)
} else if(graph == "grid5x5_1")
{
	graph <- igraph::make_lattice(dimvector = c(5,5))
	capacityMatrix1 <- getCapacityMatrix(rho = 0.6, epsilon = epsilon, bi = 8)
	capacityList <- replicate(40, capacityMatrix1, simplify=FALSE)
} else if(graph == "grid4x4_1")
{
	graph <- igraph::make_lattice(dimvector = c(4,4))
	capacityMatrix1 <- getCapacityMatrix(rho = 0.6, epsilon = epsilon, bi = 8)
	capacityList <- replicate(24, capacityMatrix1, simplify=FALSE)
} else if(graph == "grid3x3_1")
{
	graph <- igraph::make_lattice(dimvector = c(3,3))
	capacityMatrix1 <- getCapacityMatrix(rho = 0.6, epsilon = epsilon, bi = 8)
	capacityList <- replicate(12, capacityMatrix1, simplify=FALSE)
} else
{
	stop("Unknown graph")
}

if(method == "crudeMC")
{
	counter <- 1
	if(file.exists(outputFile))
	{
		load(outputFile)
		counter <- length(results)+1
	} else results <- list()
	while(counter < nReps + 1)
	{
		results[[counter]] <- crudeMC(graph = graph, capacityMatrix = capacityList, n = n, threshold = demand, seed = SCENARIO_INDEX, interestVertices = interestVertices) 
		save(results, file = tmpFile)
		file.rename(from = tmpFile, to = outputFile)
		counter <- counter + 1
	}
} else if(method == "pmc")
{
	counter <- 1
	if(file.exists(outputFile))
	{
		load(outputFile)
		counter <- length(results)+1
	} else results <- list()
	while(counter < nReps + 1)
	{
		results[[counter]] <- pmc(graph = graph, capacityMatrix = capacityList, n = n, threshold = demand, seed = SCENARIO_INDEX + counter * 100000L, interestVertices = interestVertices, undirected = TRUE)
		save(results, file = tmpFile)
		file.rename(from = tmpFile, to = outputFile)
		counter <- counter + 1
	}
} else if(method == "turnipSingle")
{
	counter <- 1
	if(file.exists(outputFile))
	{
		load(outputFile)
		counter <- length(results)+1
	} else results <- list()
	while(counter < nReps + 1)
	{
		results[[counter]] <- turnip(graph = graph, capacityMatrix = capacityList, n = n, threshold = demand, seed = SCENARIO_INDEX + counter * 100000L, interestVertices = interestVertices, useAllPointsMaxFlow = FALSE, undirected = TRUE)
		save(results, file = tmpFile)
		file.rename(from = tmpFile, to = outputFile)
		counter <- counter + 1
	}
} else if(method == "turnipFull3")
{
	counter <- 1
	if(file.exists(outputFile))
	{
		load(outputFile)
		counter <- length(results)+1
	} else results <- list()
	while(counter < nReps + 1)
	{
		results[[counter]] <- turnip(graph = graph, capacityMatrix = capacityList, n = n, threshold = demand, seed = SCENARIO_INDEX + counter * 100000L, interestVertices = interestVertices, useAllPointsMaxFlow = TRUE, allPointsMaxFlowIncrement = 3L, undirected = TRUE)
		save(results, file = tmpFile)
		file.rename(from = tmpFile, to = outputFile)
		counter <- counter + 1
	}
} else if(method == "turnipFull2")
{
	counter <- 1
	if(file.exists(outputFile))
	{
		load(outputFile)
		counter <- length(results)+1
	} else results <- list()
	while(counter < nReps + 1)
	{
		results[[counter]] <- turnip(graph = graph, capacityMatrix = capacityList, n = n, threshold = demand, seed = SCENARIO_INDEX + counter * 100000, interestVertices = interestVertices, useAllPointsMaxFlow = TRUE, allPointsMaxFlowIncrement = 2L, undirected = TRUE)
		save(results, file = tmpFile)
		file.rename(from = tmpFile, to = outputFile)
		counter <- counter + 1
	}
} else if (method == "turnipFull1")
{
	counter <- 1
	if(file.exists(outputFile))
	{
		load(outputFile)
		counter <- length(results)+1
	} else results <- list()
	while(counter < nReps + 1)
	{
		results[[counter]] <- turnip(graph = graph, capacityMatrix = capacityList, n = n, threshold = demand, seed = SCENARIO_INDEX + counter * 100000, interestVertices = interestVertices, useAllPointsMaxFlow = TRUE, allPointsMaxFlowIncrement = 1L, undirected = TRUE)
		save(results, file = tmpFile)
		file.rename(from = tmpFile, to = outputFile)
		counter <- counter + 1
	}
} else if(method == "gsFS")
{
	counter <- 1
	if(file.exists(outputFile))
	{
		load(outputFile)
		counter <- length(results)+1
	} else 
	{
		results <- list()
		pilot <- generalisedSplittingAdaptiveEvolution(graph = graph, capacityMatrix = capacityList, n = n/100, seed = SCENARIO_INDEX + counter * 100000 - 1, interestVertices = interestVertices, verbose=FALSE, fraction = 10, level = demand)
		factors <- rep(10, length(pilot@times)-1)
		save(pilot, factors, results, file = tmpFile)
		file.rename(from = tmpFile, to = outputFile)
	}
	while(counter < nReps + 1)
	{
		results[[counter]] <- generalisedSplittingFixedFactorsEvolution(graph = graph, capacityMatrix = capacityList, n = n, times = pilot@times, seed = SCENARIO_INDEX + counter * 100000, interestVertices = interestVertices, verbose=FALSE, factors = factors, level = demand)
		save(pilot, factors, results, file = tmpFile)
		file.rename(from = tmpFile, to = outputFile)
		counter <- counter + 1
	}
} else
{
	stop("Unrecognized method")
}
