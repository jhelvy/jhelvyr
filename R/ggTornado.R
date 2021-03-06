#' Creates a "tornado" plot using the tidyverse library
#'
#' This function creates a "tornado" plot using the tidyverse library.
#' @param df A data frame of the results of a sensitivity analysis.
#' @param baseline The baseline value that the sensitivity analysis is compared to.
#' @param varName The df column identifying the variable being varied.
#' @param levelName The df column identifying the sensitivity case level (high or low, relative to the baseline).
#' @param valName The df column identifying the value of the variable being varied.
#' @param resultName The df column identifying the result of the output value at the varied variable value.
#' @param xlab The x-axis label (defaults to 'Result').
#' @param ylab The y-axis label (defaults to 'Parameter').
#' @export
#' @examples
#'
#' # Create an example data frame of a sensitivity analysis - columns:
#' # 'var'      = The name of the variable being varied.
#' # 'level'    = High or Low (relative to the baseline).
#' # 'varValue' = The value of the variable being varied.
#' # 'result'   = The result of the output value at the varied variable value.
#' df = data.frame(
#'     var      = c('price', 'price', 'fuelEconomy', 'fuelEconomy',
#'                  'accelTime', 'accelTime'),
#'     level    = rep(c('high', 'low'), 3),
#'     varValue = c(10, 20, 25, 15, 10, 6),
#'     result   = c(0.95, 0.15, 0.90, 0.60, 0.85, 0.75))
#'
#' # Define the baseline analysis result:
#' baseline = 0.8
#'
#' # Make a tornado plot of the sensitivity analysis results:
#' library(tidyverse)
#' plot = ggTornado(df=df, baseline=baseline, varName='var',
#'                  levelName='level', valName='varValue',
#'                  resultName='result', xlab='Result',
#'                  ylab='Parameter')
#' plot

ggTornado = function(
    df,
    baseline,
    varName    = 'var',
    levelName  = 'level',
    valName    = 'val',
    resultName = 'result',
    xlab       = 'Result',
    ylab       = 'Parameter') {

    # Create a new data frame for plotting
    newDf = df[c(varName, levelName, valName, resultName)]
    colnames(newDf) = c('var', 'level', 'val', 'result')

    newDf = newDf %>%
        # "Center" the result around the baseline result (so baseline is at 0)
        mutate(result = result - baseline) %>%
        # Compute the range in change from low to high levels for sorting
        group_by(var) %>%
        mutate(resultRange = sum(abs(result)))

    # Compute labels for the x-axis
    lb        = floor(10*min(newDf$result))/10
    ub        = ceiling(10*max(newDf$result))/10
    breaks    = seq(lb, ub, (ub - lb) / 5)
    breakLabs = round(breaks + baseline, 2)

    # Make the tornado diagram
    plot = ggplot(newDf,
        # Use 'fct_reorder' to order the variables according to shareRange
        aes(x=fct_reorder(var, resultRange), y=result, fill=level)) +
        geom_bar(stat='identity', width=0.6) +
        # Add labels on bars
        geom_text(aes(label=val), vjust=0.5) +
        scale_y_continuous(limits=c(lb, ub), breaks=breaks, labels=breakLabs) +
        labs(x=ylab, y=xlab) +
        theme_bw() +
        # Remove legend
        theme(legend.position='none') +
        coord_flip()

    return(plot)
}
