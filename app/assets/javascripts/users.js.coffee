$ ->
  if $('#token a').length > 0
    $('#token a').prop 'href', '/token?nick=' + $('#user_nick').val()

  $('#token a').click ->
    $('#token a').prop 'href', '/token?nick=' + $('#user_nick').val()

  if $('#chart').length > 0
    axisOptions =
        allowDecimals: false
        gridLineWidth: 0
        labels:
          enabled: false
        lineWidth: 0
        tickWidth: 0
        title:
          text: null

    chartOptions =
      chart:
        backgroundColor: 'rgba(0, 0, 0, 0)'
        defaultSeriesType: 'line'
        height: 200
        renderTo: 'chart'
      legend:
        enabled: false
      plotOptions:
        line:
          marker:
            enabled: false
            states:
              hover:
                enabled: true
                lineWidth: 2
                radius: 4
      series: [{color: '#b5e9ff'}]
      tooltip:
        formatter: ->
          '<b>Game:</b> ' + this.x + ' <b>Rating:</b> ' + parseInt(this.y)
      title:
        text: null
      xAxis: axisOptions
      yAxis: axisOptions

    $.get $(location).attr('href') + '/ratings.json', (ratings) ->
      chartOptions.series[0].data = ratings
      new Highcharts.Chart chartOptions