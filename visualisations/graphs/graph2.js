import { getRemoteData, getLocalData } from '../getData.js';

async function createGraph2(gql_query) {

    let gql_response_data = await getRemoteData(gql_query);

    // Declare the chart dimensions and margins.
    const width = 640;
    const height = 400;
    const marginTop = 20;
    const marginRight = 20;
    const marginBottom = 30;
    const marginLeft = 40;

    const parseUnixTime = d3.utcParse("%s");

    const x = d3.scaleUtc(d3.extent(gql_response_data, d => parseUnixTime(d._id)), [marginLeft, width - marginRight]);
    const y = d3.scaleLinear([0, d3.max(gql_response_data, d => d.sumNodes)], [height - marginBottom, marginTop]);

    // Declare the line generator.
    const line = d3.line()
        .x(d => x(parseUnixTime(d._id)))
        .y(d => y(d.sumNodes));

    // Create the SVG container.
    const svg = d3.create("svg")
        .attr("width", width)
        .attr("height", height);

    // Add the x-axis.
    svg.append("g")
        .attr("transform", `translate(0,${height - marginBottom})`)
        .call(d3.axisBottom(x).ticks(width / 80).tickSizeOuter(0));

    // Add the y-axis, remove the domain line, add grid lines and a label.
    svg.append("g")
        .attr("transform", `translate(${marginLeft},0)`)
        .call(d3.axisLeft(y).ticks(height / 40))
        .call(g => g.select(".domain").remove())
        .call(g => g.selectAll(".tick line").clone()
            .attr("x2", width - marginLeft - marginRight)
            .attr("stroke-opacity", 0.1));

    // Append a path for the line.
    svg.append("path")
        .attr("fill", "none")
        .attr("stroke", "black")
        .attr("stroke-width", 1.5)
        .attr("d", line(gql_response_data));

    return svg

};

export { createGraph2 };