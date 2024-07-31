// fetch data from graphql endpoint
async function getRemoteData(query) {
    const url = "http://localhost:4000/api";
    try {
        const myHeaders = new Headers();
        myHeaders.append("Content-Type", "application/json");
        const myRequest = new Request(url, {
            method: "POST",
            body: query,
            headers: myHeaders,
        });
        const response = await fetch(myRequest);
        if (!response.ok) {
            throw new Error(`Response status: ${response.status}`);
        }
        const json = await response.json();
        return Object.values(json.data)[0];
    } catch (error) {
        console.error(error.message);
    }
}

async function getLocalData() {
    try {
        const response = await fetch("test_response.json");
        const json = await response.json();
        return json.data.latest_nodes_per_community;
    }
    catch (error) {
        console.error(error.message);
    }
}

export {getRemoteData, getLocalData};