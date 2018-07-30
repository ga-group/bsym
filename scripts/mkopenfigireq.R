library(data.table)

mkopenfigireq <- function(x, idtype="ID_BB_GLOBAL")
{
	y <- data.table(id=unique(x))
	if (idtype == "TICKER") {
		y[, c("sym", "bps", "sec") := tstrsplit(id, " ", fixed=T)]
		y[, paste0('[{"idType":"TICKER", "idValue":"',sym,'", "exchCode":"',bps,'"}]')]
	} else {
		y[, paste0('[{"idType":"',idtype,'", "idValue":"',id,'"}]')]
	}
}
