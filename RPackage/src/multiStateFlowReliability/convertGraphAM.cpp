#include "convertGraph.h"
#include "context.h"
namespace multistateTurnip
{
	void convertGraphAM(SEXP graph_sexp, typename Context::inputGraph& graphRef)
	{
		Rcpp::S4 graph_s4;
		try
		{
			graph_s4 = Rcpp::as<Rcpp::S4>(graph_sexp);
		}
		catch(Rcpp::not_compatible&)
		{
			throw std::runtime_error("Input graph must be an S4 object");
		}
		if(Rcpp::as<std::string>(graph_s4.attr("class")) != "graphAM")
		{
			throw std::runtime_error("Input graph must have class graphAM");
		}
		
		Rcpp::RObject adjMat_obj;
		try
		{
			adjMat_obj = Rcpp::as<Rcpp::RObject>(graph_s4.slot("adjMat"));
		}
		catch(Rcpp::not_compatible&)
		{
			throw std::runtime_error("Error extracting slot adjMat of input graph");
		}

		Rcpp::NumericMatrix adjMat;
		try
		{
			adjMat = Rcpp::as<Rcpp::NumericMatrix>(adjMat_obj);
		}
		catch(Rcpp::not_compatible&)
		{
			throw std::runtime_error("Error extracting slot adjMat of input graph");
		}
		
		int nVertices = adjMat.nrow();
		if(adjMat.ncol() != nVertices)
		{
			throw std::runtime_error("Slot adjMat of input graph must be a square matrix");
		}

		graphRef = Context::inputGraph(nVertices);
		for(int i = 0; i < nVertices; i++)
		{
			for(int j = 0; j < nVertices; j++)
			{
				if(adjMat(i, j) > 0)
				{
					boost::add_edge((std::size_t)i, (std::size_t)j, graphRef);
				}
			}
		}
	}
	void convertGraphDirectedAM(SEXP graph_sexp, typename ContextDirected::inputGraph& graphRef)
	{
		Rcpp::S4 graph_s4;
		try
		{
			graph_s4 = Rcpp::as<Rcpp::S4>(graph_sexp);
		}
		catch(Rcpp::not_compatible&)
		{
			throw std::runtime_error("Input graph must be an S4 object");
		}
		if(Rcpp::as<std::string>(graph_s4.attr("class")) != "graphAM")
		{
			throw std::runtime_error("Input graph must have class graphAM");
		}
		
		Rcpp::RObject adjMat_obj;
		try
		{
			adjMat_obj = Rcpp::as<Rcpp::RObject>(graph_s4.slot("adjMat"));
		}
		catch(Rcpp::not_compatible&)
		{
			throw std::runtime_error("Error extracting slot adjMat of input graph");
		}

		Rcpp::NumericMatrix adjMat;
		try
		{
			adjMat = Rcpp::as<Rcpp::NumericMatrix>(adjMat_obj);
		}
		catch(Rcpp::not_compatible&)
		{
			throw std::runtime_error("Error extracting slot adjMat of input graph");
		}
		
		int nVertices = adjMat.nrow();
		if(adjMat.ncol() != nVertices)
		{
			throw std::runtime_error("Slot adjMat of input graph must be a square matrix");
		}

		graphRef = ContextDirected::inputGraph(nVertices);
		int counter = 0;
		for(int i = 0; i < nVertices; i++)
		{
			for(int j = 0; j < nVertices; j++)
			{
				if(adjMat(i, j) > 0)
				{
					boost::add_edge((std::size_t)i, (std::size_t)j, counter, graphRef);
					counter++;
				}
			}
		}
	}
}
