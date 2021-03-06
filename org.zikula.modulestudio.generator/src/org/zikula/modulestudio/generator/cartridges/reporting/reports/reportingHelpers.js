
function countRelations(incoming, outgoing)
{
    return countElements(incoming) + countElements(outgoing);
}

function countRows(row, attribute)
{
    var sum;
    sum = countElements(row);
    if (attribute['geographical']) {
        sum += 2;
    }
    if (attribute['standardFields']) {
        sum += 5;
    }
    if (attribute['tree']) {
        sum += 6;
    }

    return sum;
}

function countElements(row)
{
    if (row.length == 0) {
        return 0;
    }

    return row.split("\n").length;
}

function calculateComplexityApplicationData(columns, relations)
{
    if (relations < 2 && columns > 15 || relations < 3 && columns > 4 && columns < 16 || relations >= 3 && columns < 5) {
        return 1;
    } else if (relations < 3 && columns > 15 || relations >= 3 && columns > 4) {
        return 2;
    } else{
        return 0;
    }
}

function calculateComplexityInputs(fields, relations)
{
    if (relations < 2 && fields > 15 || relations < 3 && fields > 4 && fields < 16 || relations >= 3 && fields < 5) {
        return 1;
    } else if (relations < 3 && fields > 15 || relations >= 3 && fields > 4) {
        return 2;
    } else {
        return 0;
    }
}

function calculateComplexityOutputs(fields, relations)
{    
    if (relations < 2 && fields > 50 || relations < 6 && fields > 19 && fields < 51 || relations > 5 && fields < 20) {
        return 1;
    } else if (relations < 6 && fields > 50 || relations > 5 && fields > 19) {
        return 2;
    } else {
        return 0;
    }
}

function sumUp(source)
{
    sum = 0;
    for (i = 0;i < 3; i++) {
        sum += parseInt(source[i]);
    }
    return sum;
}

