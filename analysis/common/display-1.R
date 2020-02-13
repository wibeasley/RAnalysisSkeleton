# This file has graphing & table functions used in reports

palette_model         <- c("C1"="#446699",  "SC"="#ea573d", "PAT"="#615b70", "P4"="#70af81") #"HFA"="#fb9a62",
palette_miechv        <- c("TRUE"="#1765a2", "FALSE"="#4aab5e")    # http://colrd.com/image-dna/24016/

repo_theme <- function( base_size = 8 ) {
  ggplot2::theme_light(base_size=base_size) +
  ggplot2::theme(title             = ggplot2::element_text(color="gray20")) +
  ggplot2::theme(axis.text         = ggplot2::element_text(color="gray40")) +
  ggplot2::theme(axis.title        = ggplot2::element_text(color="gray40")) +
  ggplot2::theme(panel.border      = ggplot2::element_rect(color="gray80")) +
  ggplot2::theme(axis.ticks        = ggplot2::element_blank()) +
  ggplot2::theme(legend.position   = "none")
}
col_types_annotation <- function() {
  readr::cols_only(
    # date           = readr::col_date(format = ""),
    date           = readr::col_integer(),
    title          = readr::col_character(),
    description    = readr::col_character(),
    color          = readr::col_character()
  )
}

spaghetti_1 <- function(
  d, response_variable, color_variable="model_name", group_variable="program_code",
  time_variable="month", facet_variable="model_name",
  width_variable="emphasis", alpha_variable="emphasis", loess_variable=facet_variable,

  path_in_annotation = "data-public/raw/programs/cqi-annotation-example.csv",

  base_size=12,
  point_size=0L, y_min=0, y_max=NA,
  main_title=NULL, x_title=NULL, y_title=NULL, sub_title=NULL,
  y_label_format=scales::comma, palette=palette_model(),
  width=c("focus"=1, "background"=.25)
  # width=c("focus"=.25, "background"=.25)
) {
  group_symbol      <- ifelse(is.null(group_variable), NULL, rlang::sym(group_variable))
  time_symbol       <- rlang::sym(time_variable)
  response_symbol   <- rlang::sym(response_variable)
  color_symbol      <- rlang::sym(color_variable)
  width_symbol      <- rlang::sym(width_variable)

  g <- ggplot(d, aes(x=!!time_symbol, y=!!response_symbol, color=!!color_symbol, size=!!width_symbol, yMin=y_min))


  if( !is.null(group_variable) & nrow(d)>0L ) {
    d_label <- d %>%
      dplyr::group_by(!!group_symbol) %>%
      dplyr::arrange(!!time_symbol) %>%
      dplyr::mutate(
        is_first  = (dplyr::row_number() == 1L),
        is_last   = (dplyr::row_number() == dplyr::n()),
      ) %>%
      dplyr::filter(is_first | is_last) %>%
      dplyr::select(
        !!group_symbol,
        !!time_symbol,
        !!response_symbol,
        !!color_symbol,
        is_first,
        is_last
      ) %>%
      dplyr::ungroup()

    d_label_left   <- d_label[d_label$is_first, ]
    d_label_right  <- d_label[d_label$is_last , ]

    g <- g +
      geom_text(mapping=aes(label=!!group_symbol), data=d_label_left , size=3, hjust=1.2, na.rm=T) + #Left endpoint
      geom_text(mapping=aes(label=!!group_symbol), data=d_label_right, size=3, hjust=-.2, na.rm=T) #Right endpoint

      # geom_text(mapping=aes_string(label=group_variable), data=d_label , size=3, hjust=1.2, na.rm=T)
    rm(d_label, d_label_left, d_label_right)
  }

  # g <- g + geom_hline(yintercept=c(median(d[[response_variable]], na.rm=T), mean(d[[response_variable]], na.rm=T)), color="gray70", linetype="F3")
  # g <- g + geom_smooth(aes_string(group=facet_variable), method="loess", color="gray30", na.rm=TRUE)
  # g <- g + annotate("text", x=max(d[[time_variable]], na.rm=T), y=Inf, label=sub_title, hjust=1, vjust=1)

  if( !is.null(loess_variable) ) {
    g <- g + geom_smooth(aes(group=!!rlang::sym(loess_variable)), method="loess", color="gray80", size=4, alpha=.1, na.rm=T, se=F)
  }
  if( !is.na(y_max) ) {
    g <- g + coord_cartesian(ylim=c(y_min, y_max))
  }

  g <- g + geom_line(aes_string(group=group_variable, alpha=alpha_variable), stat="identity",  na.rm=TRUE) +
    geom_point(aes_string(group=group_variable, alpha=alpha_variable), size=point_size, stat="identity", shape=1,  na.rm=TRUE) +
    scale_y_continuous(labels=y_label_format) +
    scale_alpha_manual(values=c("focus"=1, "background"=.5))
    # scale_alpha_manual(values=c("focus"=.5, "background"=.5))
  if( !is.null(path_in_annotation) ) {
    d_annotation <- readr::read_csv(path_in_annotation, col_types=col_types_annotation(), comment="#")

    g <- g + geom_vline(data=d_annotation, aes(xintercept=as.numeric(date)), size=.25, color="gray45") +
      geom_text(data=d_annotation, aes(x=date, y=-Inf, label=title), angle=90, vjust=0, hjust=0, size=3, color="gray45")
  }

  if( !is.null(width) )
    g <- g + scale_size_manual(values=width)

  if( !is.null(palette) )
    g <- g + scale_color_manual(values=palette) #+ scale_fill_manual(values=palette)


  if( !is.null(facet_variable) )
    g <- g + facet_wrap(facet_variable,  scales="free_y")

  g <- g +
    guides(color="none") +
    guides(alpha="none") +
    guides(size="none") +
    # package_theme(base_size) +
    theme_minimal(base_size) +
    labs(title=main_title, x=x_title, y=y_title, subtitle=sub_title)

  return( g )
}

create_palette <- function( spaghetti_id, rainbow_start=30, rainbow_end=300, rainbow_c=100, rainbow_l=50 ) {
  # strand_count <- dplyr::n_distinct(spaghetti_id)
  strand_name   <- sort(unique(spaghetti_id))
  strand_count  <- length(strand_name)

  if( strand_count == 2L ) {
    # palette_strand    <- c("#fd8450", "#b177fc") # http://colrd.com/image-dna/36377/
    palette_strand    <- c("#057871", "#9c8a4a") # http://colrd.com/image-dna/24034/

  } else if( strand_count <= 9L ) {
    palette_strand    <- RColorBrewer::brewer.pal(strand_count,"Set1")
  } else {
    # stop("Only 12 providers are currently supported by this palette-generating function.")
    # palette_strand    <- rainbow(strand_count)
    palette_strand    <- colorspace::rainbow_hcl(strand_count, start=rainbow_start, end=rainbow_end, c=rainbow_c, l=rainbow_l)
  }

  names(palette_strand) <- strand_name

  palette_strand
}

histogram_2 <- function(
  d_observed,
  variable_name,
  bin_width               = NULL,
  main_title              = base::gsub("_", " ", variable_name, perl=TRUE),
  sub_title               = NULL,
  # caption                 = paste0("each bin is ", scales::comma(bin_width), " units wide"),
  tab_title               = paste0("\n\n### ", base::gsub("_", " ", variable_name, perl=TRUE), "\n\n"),
  x_title                 = variable_name,
  y_title                 = "Count",
  x_axis_format           = scales::comma,
  x_limits                = NULL,
  hover_text_template     = "There were {count} occasions with\n values between {boundary_left_pretty} and {boundary_right_pretty}.",
  # new_tab                 = FALSE,
  rounded_digits          = 0L,
  font_base_size          = 12
) {

  if( !inherits(d_observed, "data.frame") )
    stop("`d_observed` should inherit from the data.frame class.")


  # Uses d3 formats: https://github.com/d3/d3-format/blob/master/README.md#locale_format
  # percent format example: https://stackoverflow.com/questions/42043633/format-y-axis-as-percent-in-plot-ly
  # comma format example: https://stackoverflow.com/questions/43436009/change-comma-and-thousand-separator-in-tick-labels

  x_axis_format_string <- deparse(x_axis_format)
  if( identical(x_axis_format_string, deparse(scales::comma_format())) ) {
    tickformat <- paste0(",.", rounded_digits, "f")
  } else if( identical(x_axis_format_string, deparse(scales::percent_format())) ) {
    tickformat <- ",.0%"
  } else {
    tickformat <- paste0(".", rounded_digits, "f")
  }

  x               <- d_observed[[variable_name]]
  # missing_count <- sum(is.na(x))
  x               <- x[!is.na(x)]
  non_empty       <- (nrow(d_observed) >= 1L)

  if( non_empty ) {
  } else {
    main_title <- paste0("Empty: ", main_title)
    caption    <- "The variable contains only missing values.\nThere is nothing to graph."
  }

  if( !is.null(x_limits) & !is.null(bin_width) ) {
    histogram_breaks <- pretty(x_limits, n = diff(range(x_limits)) / bin_width)
  } else if( 1L<=length(x) & !is.null(bin_width) ) {
    histogram_breaks <- pretty(x, n = diff(range(x)) / bin_width)
  } else if( 1L<=length(x) & !is.null(x_limits) ) {
    histogram_breaks <- pretty(c(x, x_limits), n=7)
  } else if( length(x)==0L & !is.null(x_limits) ) {
    histogram_breaks <- x_limits
  } else if( length(x)==0L ) {
    histogram_breaks <- c(0, 1)
  } else  {
    histogram_breaks <- pretty(x, n=7)
  }
  # browser()

  histrv <- hist(
    x       = x,
    breaks  = histogram_breaks,
    right   = FALSE,       # The left boundary is closed/inclusive.
    plot    = FALSE
  )

  ds_stoplight_bin <- tibble::tibble(
    boundary_left   = histrv$breaks[-length(histrv$breaks)],
    boundary_right  = histrv$breaks[-1],
    count           = histrv$counts
  ) %>%
  dplyr::mutate(
    midpoint        = (boundary_right + boundary_left) / 2,
    width           = (boundary_right - boundary_left),

    boundary_left_pretty   = x_axis_format(boundary_left   ),
    boundary_right_pretty  = x_axis_format(boundary_right  ),
    midpoint_pretty        = x_axis_format(midpoint        ),
    width_pretty           = x_axis_format(width           ),

    #category        = cut(boundary_left, breaks=c(-Inf, .3, 1.4, 3, Inf), labels = c("Good", "Ok", "Bad", "Jesum")),
    category        = cut(boundary_left, breaks=c(-Inf, Inf), labels = c("")),
    hover_text      = glue::glue_data(., hover_text_template)
  )

  title_graph_font <- list(
    family  = "'Oswald', sans-serif",
    size    = 16,
    color   = "#333"
  )
  title_axis_font <- list(
    family  = "'Oswald', sans-serif",
    size    = 22,
    color   = "#666"
  )
  label_axis_font <- list(
    family  = "'Oswald', sans-serif",
    size    = 18,
    color   = "#888"
  )


  if( !is.null(tab_title) ) {
    cat(tab_title)
  }

  plot_ly(ds_stoplight_bin,  alpha = 0.6) %>%
    add_bars(
      x=~midpoint, y=~count, width=~width, color=~category, text=~count, hovertext=~hover_text,
      hoverinfo = 'text',
      # marker = list(line = list(color = '#AAAAAA', width = 1.5)), colors = c("#FF99cc", "#0dbab1","#ffd400", "#ff1a1a" )
      marker = list(line = list(color = '#AAAAAA', width = 1.5)), colors = c("#EBEBEB")
    ) %>%
    layout(
      title   = paste0("\n", main_title),
      font    = title_graph_font,
      xaxis   = list(
        title           = x_title,
        zeroline        = FALSE,
        titlefont       = title_axis_font,
        tickfont        = label_axis_font,
        autotick        = TRUE,
        tickformat      = tickformat,
        dtick           = .5
      ),
      yaxis = list(
        title           = y_title,
        # hoverformat   = '.2f',
        titlefont       = title_axis_font,
        tickfont        = label_axis_font
      )
    )
}


# activity_scatter <- function( d_plot, x_name=NULL, color_name=NULL, variable_name="Count", #sizeName=NULL,
#   main_title=NULL, x_title=NULL, y_title=NULL, log10_scale=FALSE, y_label_format=scales::comma, base_size=8, palette=NULL
# ) {
#
#   g <- ggplot(d_plot, aes_string(x=x_name, y=variable_name, label=x_name, color=color_name, y_min=0) ) + #, size=sizeName
#    geom_text(size=4, fontface=2, na.rm=TRUE)
#   if( log10_scale ) {
#     g <- g + scale_y_continuous(labels=scales::comma_format(), trans="log10", breaks=c(1, 5, 10, 50, 100, 500,  1000, 5000 )) +
#       annotation_logticks(sides="l")
#     #     g <- g + scale_y_log10(breaks = trans_breaks("log10", function(x) 10^x, n=3),
#     #                            labels = trans_format("log10",  function(x) 10^x), #General placement
#     # #                            labels = trans_format("log10", math_format(10^.x)), #General placement
#     # #                            labels =c(0, 1, 10, 100, 1000), #Works well when the bin sizes ranges from 0 to 1000.
#     #                            minor_breaks=log10(5) + -1:3)
#   }
#   if( !log10_scale ) {
#     g <- g + scale_y_continuous(labels=y_label_format) #percent_format()
#   }
#   if( !is.null(palette) )
#     g <- g + scale_color_manual(values=palette) +
#       guides(color="none", size="none") +
#       labs(title=main_title, x=x_title, y=y_title) +
#       repo_theme(base_size)
#   return( g )
# }
#
# activity_each_month <- function(
#   d_plot, color_variable=NULL, month_variable="Month", response_variable="Count", width_variable=NULL, loess_variable=NULL,
#   y_min=0, y_max=NA,
#   main_title=NULL, x_title=NULL, y_title=NULL, y_label_format=scales::comma, base_size=8, palette=NULL, width=NULL
# ) {
#
#   ds_label_left  <- d_plot[d_plot[[month_variable]] == min(d_plot[[month_variable]], na.rm=T), ]
#   ds_label_right <- d_plot[d_plot[[month_variable]] == max(d_plot[[month_variable]], na.rm=T), ]
#
#   g <- ggplot(d_plot, aes_string(x=month_variable, y=response_variable, color=color_variable, size=width_variable, y_min=y_min)) +
#     geom_hline(yintercept=c(median(d_plot[[response_variable]], na.rm=T), mean(d_plot[[response_variable]], na.rm=T)), color="gray70", linetype="F3") +
#     geom_text(mapping=aes_string(label=color_variable), data=ds_label_left , size=3, hjust=1.2, na.rm=T) # Left endpoint +
#     geom_text(mapping=aes_string(label=color_variable), data=ds_label_right, size=3, hjust=-.2, na.rm=T) # Right endpoint
#
#   if( !is.null(loess_variable) ) {
#     g <- g + geom_smooth(aes_string(group=loess_variable), method="loess", color="gray10", fill="gray75", na.rm=T)
#   }
#   if( !is.na(y_max) ) {
#     g <- g + coord_cartesian(ylim=c(y_min, y_max))
#   }
#
#   g <- g + geom_line(stat="identity", alpha=.5, na.rm=TRUE) +
#     scale_y_continuous(labels=y_label_format)
#
#   if( !is.null(width) )
#     g <- g + scale_size_manual(values=width)
#
#   if( !is.null(palette) )
#     g <- g + scale_color_manual(values=palette) +
#       guides(color="none") +
#       labs(title=main_title, x=x_title, y=y_title) +
#       repo_theme(base_size)
#
#   return( g )
# }
