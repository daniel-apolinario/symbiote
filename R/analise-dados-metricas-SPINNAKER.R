# requires  package;
# 1) tidyverse
# 2) randtests
library(tidyverse)
library(randtests)
# Lê os dados das métricas SCF, ADCS, Gini-ADS e Gini-AIS para todas as aplicações do experimento
results=read.csv("/home/daniel/Documentos/mestrado-2018/projeto/grafos-dependencia/gini-results-summary.csv")
results
summary(results)

#pdf("/home/daniel/Google Drive/note-17/Documentos/mestrado-2018/resultados-metricas.pdf")

# Separa em dataframes diferentes para cada métrica
results_GINI_ADS=results[, c(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23)]
results_GINI_AIS=results[, c(1,2,3,4,5,6,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40)]
results_SCF=results[, c(1,2,3,4,5,6,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57)]
results_ADCS=results[, c(1,2,3,4,5,6,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74)]

# cria função que retorna resultado de análise de tendência para séries temporais usando o teste de Cox Stuart
getTrendAnalysis = function(x){
  test1 <- cox.stuart.test(x, alternative="left.sided")$p.value
  test2 <- cox.stuart.test(x, alternative="right.sided")$p.value
  if(test1 < 0.05){
    return("DOWNWARD")
  }else if(test2 < 0.05){
    return("UPWARD")
  }else{
    return("NO TREND")
  }
}
# cria função que retorna p-value de análise de tendência para séries temporais usando o teste de Cox Stuart
getTrendAnalysisPvalue = function(x){
  test1 <- cox.stuart.test(x, alternative="left.sided")$p.value
  test2 <- cox.stuart.test(x, alternative="right.sided")$p.value
  if(test1 < 0.05){
    return(test1)
  }else if(test2 < 0.05){
    return(test2)
  }else{
    ifelse(test1 < test2, test1, test2)
  }
}

par(mfrow = c(2, 2), mar = c(2.5, 2.5, 2.5, 2.5), mgp = c(1.5, 0.6,0))

col_vector<-c('#e6194b', '#3cb44b', '#ffe119', '#4363d8', '#f58231', '#911eb4', '#46f0f0', '#f032e6', '#bcf60c', '#fabebe', '#008080', '#e6beff', '#9a6324', '#fffac8', '#800000', '#aaffc3', '#808000', '#ffd8b1', '#000075', '#808080', '#ffffff', '#000000')

plotGraphicPerWindowRelease = function(ts_results, col_vector, j, window_trend, trend, ylab, main, xplot, yplot){
  ts.plot(ts_results, gpars=list(xlab="Release", ylab=ylab, col=col_vector[4], type="o", xaxt="n"), main=paste(main,j-6 ,sep="-"))
  abline(v= c((j - 6),(j + window_trend -7)), col=col_vector[1], lty=2, lwd=3 )
  legend(x=xplot, y=yplot, cex=1, trend, bty = "n", text.col = col_vector[19]) 
  axis(side=1, at=seq(1,17,by=1),labels=c("1.6","1.7","1.8","1.9","1.10","1.11","1.12","1.13","1.14","1.15","1.16","1.17","1.18","1.19","1.20","1.21","1.22") )
}

# Number of releases used to create a window to calculate the trends
window_trend =17
number_of_releases=17
window_qty=number_of_releases - window_trend + 1

# Transform the data into time series
ts_results_GINI_ADS=ts(t(results_GINI_ADS[,7:23]))
ts_results_GINI_AIS=ts(t(results_GINI_AIS[,7:23]))
ts_results_ADCS=ts(t(results_ADCS[,7:23]))
ts_results_SCF=ts(t(results_SCF[,7:23]))

#rownames(ts_results_GINI_ADS)=c("1.6.2","1.7.8","1.8.7","a","a","a","a","a","a","a","a","a","a","a","a","a","a")
#axis(side=1, labels=c("1.6.2","1.7.8","1.8.7","a","a","a","a","a","a","a","a","a","a","a","a","a","a"))

results_matrix=cbind(ts_results_GINI_AIS, ts_results_GINI_ADS, ts_results_ADCS, ts_results_SCF)

  
  results_GINI_AIS$TOTAL_TREND=NA
  for(i in 1:(number_of_releases - window_trend + 1)){
    release= i + window_trend - 2
    column_name = paste("TREND", release, sep = "_")
    results_GINI_AIS[get("column_name")]=NA
  }
  for(i in 1:dim(results_GINI_AIS)[1]){
    results_GINI_AIS$TOTAL_TREND[i]=getTrendAnalysis(ts(results_GINI_AIS[i,7:23]))
    for(j in 7: (window_qty + 6)){
      column_name = paste("TREND", window_trend + j - 7, sep = "_")
      results_GINI_AIS[[get("column_name")]][i]=getTrendAnalysis(ts(results_GINI_AIS[i, j : (j + window_trend - 1)]))
      plotGraphicPerWindowRelease(ts_results_GINI_AIS, col_vector, j, window_trend, results_GINI_AIS[[get("column_name")]][i], "SID", "SID Evolution", (j - 7 + 0.5), 0.315)
    }
  }

  results_GINI_ADS$TOTAL_TREND=NA
  for(i in 1:(number_of_releases - window_trend + 1)){
    release= i + window_trend - 2
    column_name = paste("TREND", release, sep = "_")
    results_GINI_ADS[get("column_name")]=NA
  }
  for(i in 1:dim(results_GINI_ADS)[1]){
    results_GINI_ADS$TOTAL_TREND[i]=getTrendAnalysis(ts(results_GINI_ADS[i,7:23]))
    for(j in 7: (window_qty + 6)){
      column_name = paste("TREND", window_trend + j - 7, sep = "_")
      print(ts(results_GINI_ADS[i, j : (j + window_trend - 1)]))
      results_GINI_ADS[[get("column_name")]][i]=getTrendAnalysis(ts(results_GINI_ADS[i, j : (j + window_trend - 1)]))
      plotGraphicPerWindowRelease(ts_results_GINI_ADS, col_vector, j, window_trend, results_GINI_ADS[[get("column_name")]][i], "SDD", "SDD Evolution", (j - 7 + 1), 0.49)
    }
  }
  
  results_ADCS$TOTAL_TREND=NA
  for(i in 1:(number_of_releases - window_trend + 1)){
    release= i + window_trend - 2
    column_name = paste("TREND", release, sep = "_")
    results_ADCS[get("column_name")]=NA
  }
  for(i in 1:dim(results_ADCS)[1]){
    results_ADCS$TOTAL_TREND[i]=getTrendAnalysis(ts(results_ADCS[i,7:23]))
    for(j in 7: (window_qty + 6)){
      column_name = paste("TREND", window_trend + j - 7, sep = "_")
      results_ADCS[[get("column_name")]][i]=getTrendAnalysis(ts(results_ADCS[i, j : (j + window_trend - 1)]))
      #plotGraphicPerWindowRelease(ts_results_ADCS, col_vector, j, window_trend, results_ADCS[[get("column_name")]][i], "ADCS", "ADCS-Evolution", (j - 7 + 0.5), 3.05)
      plotGraphicPerWindowRelease(ts_results_ADCS, col_vector, j, window_trend, results_ADCS[[get("column_name")]][i], "ADCS", "ADCS-Evolution", (j - 7 + 0.5), 2.99)
    }
  }
  
  results_SCF$TOTAL_TREND=NA
  for(i in 1:(number_of_releases - window_trend + 1)){
    release= i + window_trend - 2
    column_name = paste("TREND", release, sep = "_")
    results_SCF[get("column_name")]=NA
  }
  for(i in 1:dim(results_SCF)[1]){
    results_SCF$TOTAL_TREND[i]=getTrendAnalysis(ts(results_SCF[i,7:23]))
    for(j in 7: (window_qty + 6)){
      column_name = paste("TREND", window_trend + j - 7, sep = "_")
      results_SCF[[get("column_name")]][i]=getTrendAnalysis(ts(results_SCF[i, j : (j + window_trend - 1)]))
      #plotGraphicPerWindowRelease(ts_results_SCF, col_vector, j, window_trend, results_SCF[[get("column_name")]][i], "SCF", "SCF-Evolution", (j - 7 + 1), 0.385)
      plotGraphicPerWindowRelease(ts_results_SCF, col_vector, j, window_trend, results_SCF[[get("column_name")]][i], "SCF", "SCF-Evolution", (j - 7 + 1), 0.375)
    }
  }
  
  # Generating graphs individually per metrics for the whole releases interval
  par(mfrow = c(1, 1))
  ts.plot(ts_results_GINI_ADS, gpars=list(xlab="Release", ylab="SDD", col=col_vector[4], type="o", xaxt="n"), main="SDD Evolution")
  legend(x=3, y=0.49, cex=1.5, results_GINI_ADS$TOTAL_TREND, bty = "n", text.col = col_vector[19]) 
  axis(side=1, at=seq(1,17,by=1),labels=c("1.6","1.7","1.8","1.9","1.10","1.11","1.12","1.13","1.14","1.15","1.16","1.17","1.18","1.19","1.20","1.21","1.22") )
  
  par(mfrow = c(1, 1))
  ts.plot(ts_results_GINI_AIS, gpars=list(xlab="Release", ylab="SID", col=col_vector[4], type="o", xaxt="n"), main="SID Evolution")
  legend(x=3, y=0.305, cex=1.5, results_GINI_AIS$TOTAL_TREND, bty = "n", text.col = col_vector[19]) 
  axis(side=1, at=seq(1,17,by=1),labels=c("1.6","1.7","1.8","1.9","1.10","1.11","1.12","1.13","1.14","1.15","1.16","1.17","1.18","1.19","1.20","1.21","1.22") )
  
  par(mfrow = c(1, 1))
  ts.plot(ts_results_ADCS, gpars=list(xlab="Release", ylab="ADCS", col=col_vector[4], type="o", xaxt="n"), main="ADCS Evolution")
  legend(x=3, y=0.305, cex=1.5, results_ADCS$TOTAL_TREND, bty = "n", text.col = col_vector[19]) 
  axis(side=1, at=seq(1,17,by=1),labels=c("1.6","1.7","1.8","1.9","1.10","1.11","1.12","1.13","1.14","1.15","1.16","1.17","1.18","1.19","1.20","1.21","1.22") )

  par(mfrow = c(1, 1))
  ts.plot(ts_results_SCF, gpars=list(xlab="Release", ylab="SCF", col=col_vector[4], type="o", xaxt="n"), main="SCF Evolution")
  legend(x=3, y=0.37, cex=1.5, results_SCF$TOTAL_TREND, bty = "n", text.col = col_vector[19]) 
  axis(side=1, at=seq(1,17,by=1),labels=c("1.6","1.7","1.8","1.9","1.10","1.11","1.12","1.13","1.14","1.15","1.16","1.17","1.18","1.19","1.20","1.21","1.22") )
  