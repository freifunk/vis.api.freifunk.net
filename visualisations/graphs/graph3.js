import { getRemoteData, getLocalData } from '../getData.js';

async function createGraph3(gql_query) {

    let gql_response_data = await getRemoteData(gql_query);

    // Declare the chart dimensions and margins.
    const width = 640;
    const height = 360;
    const marginTop = 20;
    const marginRight = 20;
    const marginBottom = 30;
    const marginLeft = 40;

    const parseUnixTime = d3.utcParse("%Y-%m-%d");

    const series = d3.stack()
        .keys(d3.union(gql_response_data.map(d => d.routingTech))) // distinct series keys, in input order
        .value(([, group], key) => group.get(key).seen) // get value for each series key and stack
        (d3.index(gql_response_data, d => parseUnixTime(d.date), d => d.routingTech)); // group by stack then series key

    // Prepare the scales for positional and color encodings.
    const x = d3.scaleUtc()
        .domain(d3.extent(gql_response_data, d => parseUnixTime(d.date)))
        .range([marginLeft, width - marginRight]);

        const y = d3.scaleLinear()
        .domain([0, d3.max(series, d => d3.max(d, d => d[1]))])
        .rangeRound([height - marginBottom, marginTop]);
  
    const color = d3.scaleOrdinal()
        .domain(series.map(d => d.key))
        .range(d3.schemeTableau10);
  
    // Construct an area shape.
    const area = d3.area()
        .x(d => x(d.data[0]))
        .y0(d => y(d[0]))
        .y1(d => y(d[1]));
  
    // Create the SVG container.
    const svg = d3.create("svg")
        .attr("width", width)
        .attr("height", height)
        .attr("viewBox", [0, 0, width, height])
        .attr("style", "max-width: 100%; height: auto;");
  
    // Add the y-axis, remove the domain line, add grid lines and a label.
    svg.append("g")
        .attr("transform", `translate(${marginLeft},0)`)
        .call(d3.axisLeft(y).ticks(height / 80))
        .call(g => g.select(".domain").remove())
        .call(g => g.selectAll(".tick line").clone()
            .attr("x2", width - marginLeft - marginRight)
            .attr("stroke-opacity", 0.1))
        .call(g => g.append("text")
            .attr("x", -marginLeft)
            .attr("y", 10)
            .attr("fill", "currentColor")
            .attr("text-anchor", "start")
            .text("Protocols in use"));
  
    // Append a path for each series.
    svg.append("g")
      .selectAll()
      .data(series)
      .join("path")
        .attr("fill", d => color(d.key))
        .attr("d", area)
      .append("title")
        .text(d => d.key);
  
    // Append the horizontal axis atop the area.
    svg.append("g")
        .attr("transform", `translate(0,${height - marginBottom})`)
        .call(d3.axisBottom(x).tickSizeOuter(0));
  
    // Return the chart with the color scale as a property (for the legend).
    // return Object.assign(svg.node(), {scales: {color}});

    return svg

};

export { createGraph3 };