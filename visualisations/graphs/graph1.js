import { getRemoteData, getLocalData } from '../getData.js';

async function createGraph1(gql_query) {

    let gql_response_data = await getRemoteData(gql_query);

    // Declare the chart dimensions and margins.
    const width = 640;
    const height = 360;
    const marginTop = 20;
    const marginRight = 20;
    const marginBottom = 30;
    const marginLeft = 40;

    // Declare the x (horizontal position) scale.
    const x = d3.scaleBand()
        .domain(d3.groupSort(gql_response_data, ([d]) => -d.nodes, (d) => d._id)) // descending frequency
        .range([marginLeft, width - marginRight])
        .padding(0.1);

    // // Declare the y (vertical position) scale.
    const y = d3.scaleLinear()
        .domain([0, d3.max(gql_response_data, (d) => d.nodes)])
        .range([height - marginBottom, marginTop]);

    // Create the SVG container.
    const svg = d3.create("svg")
        .attr("width", width)
        .attr("height", height);



    // Add the x-axis.
    svg.append("g")
        .selectAll()
        .data(gql_response_data)
        .join("rect")
        .attr("x", (d) => x(d._id))
        .attr("y", (d) => y(d.nodes))
        .attr("height", (d) => y(0) - y(d.nodes))
        .attr("width", x.bandwidth());

    // Add the x-axis and label.
    svg.append("g")
        .attr("transform", `translate(0,${height - marginBottom})`)
        .call(d3.axisBottom(x))

    // Add the y-axis and label.
    svg.append("g")
        .attr("transform", `translate(${marginLeft},0)`)
        .call(d3.axisLeft(y))
        .call(g => g.append("text")
            .attr("x", -marginLeft)
            .attr("y", 10)
            .attr("fill", "black")
            .attr("text-anchor", "start")
            .text("Nodes"));

    return svg;

}

export { createGraph1 };