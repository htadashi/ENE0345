// JavaScript equivalent of interactive MATLAB code using D3.js

// Create SVG container
document.body.style.margin = '0';
const width = window.innerWidth;
const height = window.innerHeight;

const svg = d3.select('body')
    .append('svg')
    .attr('width', width)
    .attr('height', height);

// Define dimensions for subplots
const margin = 50;
const plotWidth = (width - 3 * margin) / 2;
const plotHeight = height - 2 * margin;

// Define scales
const thetaScaleY = d3.scaleLinear()
  .domain([-2 * Math.PI, 2 * Math.PI])
  .range([plotHeight, 0]);

const thetaScaleX = d3.scaleLinear()
  .domain([-2 * Math.PI, 2 * Math.PI])
  .range([0, plotHeight]);

const xyScaleY = d3.scaleLinear()
  .domain([-2, 2])
  .range([plotHeight, 0]); 
  
const xyScaleX = d3.scaleLinear()
  .domain([-2, 2])
  .range([0, plotHeight]);   

// Subplot for theta1-theta2
const thetaGroup = svg.append('g')
    .attr('transform', `translate(${margin}, ${margin})`);

// Axes for theta1-theta2
const thetaXAxis = d3.axisBottom(thetaScaleX).ticks(5);
const thetaYAxis = d3.axisLeft(thetaScaleY).ticks(5);

thetaGroup.append('g')
    .attr('transform', `translate(0, ${plotHeight})`)
    .call(thetaXAxis);

thetaGroup.append('g')
    .call(thetaYAxis);

// Labels for theta1-theta2
svg.append('text')
    .attr('x', margin + plotWidth / 2)
    .attr('y', margin / 2)
    .attr('text-anchor', 'middle')
    .text('\u03B81 vs \u03B82');

// Draw [-pi, pi] x [-pi, pi] square in theta1-theta2 plot
const squareData = [
    { x: -Math.PI, y: -Math.PI },
    { x: Math.PI, y: -Math.PI },
    { x: Math.PI, y: Math.PI },
    { x: -Math.PI, y: Math.PI },
    { x: -Math.PI, y: -Math.PI }
];

thetaGroup.append('path')
    .datum(squareData)
    .attr('d', d3.line()
        .x(d => thetaScaleX(d.x))
        .y(d => thetaScaleY(d.y))
    )
    .attr('stroke', 'black')
    .attr('fill', 'none');

// Add X-axis label for theta plot
thetaGroup.append('text')
  .attr('x', plotWidth / 2)
  .attr('y', plotHeight + margin - 10)
  .attr('text-anchor', 'middle')
  .text('θ1');

// Add Y-axis label for theta plot
thetaGroup.append('text')
  .attr('transform', 'rotate(-90)')
  .attr('x', -plotHeight / 2)
  .attr('y', -margin + 20)
  .attr('text-anchor', 'middle')
  .text('θ2');

// Add dots for solutions
const sol1Dot = thetaGroup.append('circle')
    .attr('cx', thetaScaleX(0))
    .attr('cy', thetaScaleY(0))
    .attr('r', 8)
    .attr('fill', 'red');

const sol2Dot = thetaGroup.append('circle')
    .attr('cx', thetaScaleX(0))
    .attr('cy', thetaScaleY(0))
    .attr('r', 8)
    .attr('fill', 'blue');

// Subplot for x-y
const xyGroup = svg.append('g')
    .attr('transform', `translate(${2 * margin + plotWidth}, ${margin})`);

// Axes for x-y
const xyXAxis = d3.axisBottom(xyScaleX).ticks(5);
const xyYAxis = d3.axisLeft(xyScaleY).ticks(5);

xyGroup.append('g')
    .attr('transform', `translate(0, ${plotHeight})`)
    .call(xyXAxis);

xyGroup.append('g')
    .call(xyYAxis);

// Labels for x-y
svg.append('text')
    .attr('x', 2 * margin + plotWidth + plotWidth / 2)
    .attr('y', margin / 2)
    .attr('text-anchor', 'middle')
    .text('x vs y');

// Add X-axis label for xy plot
xyGroup.append('text')
  .attr('x', plotWidth / 2)
  .attr('y', plotHeight + margin - 10)
  .attr('text-anchor', 'middle')
  .text('x');

// Add Y-axis label for xy plot
xyGroup.append('text')
  .attr('transform', 'rotate(-90)')
  .attr('x', -plotHeight / 2)
  .attr('y', -margin + 20)
  .attr('text-anchor', 'middle')
  .text('y');

// Add cursor dot
const cursorDot = xyGroup.append('circle')
    .attr('r', 8)
    .attr('fill', 'black')
    .attr('visibility', 'hidden');

// Draw a circle in x-y plot
const circleData = d3.range(0, 2 * Math.PI, 0.01).map(theta => {
    return { x: 2 * Math.cos(theta), y: 2 * Math.sin(theta) };
});

xyGroup.append('path')
    .datum(circleData)
    .attr('d', d3.line()
        .x(d => xyScaleY(d.x))
        .y(d => xyScaleY(d.y))
    )
    .attr('stroke', 'black')
    .attr('fill', 'none');

// Draw robot linkages (1st solution)
const link1 = xyGroup.append('line')
    .attr('stroke', 'red')
    .attr('stroke-width', 2);
const link2 = xyGroup.append('line')
    .attr('stroke', 'red')
    .attr('stroke-width', 2);

// Draw robot linkages (2nd solution)
const link1_alt = xyGroup.append('line')
    .attr('stroke', 'blue')
    .attr('stroke-width', 2);
const link2_alt = xyGroup.append('line')
    .attr('stroke', 'blue')
    .attr('stroke-width', 2);    

// Add text element for coordinates display
const coordsText = svg.append('text')
    .attr('x', width / 2)
    .attr('y', height - margin / 4)
    .attr('text-anchor', 'middle')
    .text('(x, y): (0, 0)');    

// Mouse move event
svg.on('mousemove', (event) => {

    // Robot arm dimensions
    const L1 = 1; // Length of first link
    const L2 = 1; // Length of second link

    cursorDot.attr('visibility', 'visible');
    link1.attr('visibility', 'visible');
    link2.attr('visibility', 'visible');
    link1_alt.attr('visibility', 'visible');
    link2_alt.attr('visibility', 'visible');    

    const [mouseX, mouseY] = d3.pointer(event);

    // Update cursor position in x-y plot
    const x = xyScaleX.invert(mouseX - (2 * margin + plotWidth));
    const y = xyScaleY.invert(mouseY - margin);

    if (x * x + y * y <= 4) { // Inside the circle

         // Update coordinates display with 2 decimal places
        coordsText.text(`(x, y): (${x.toFixed(2)}, ${y.toFixed(2)})`);

        cursorDot
            .attr('cx', xyScaleX(x))
            .attr('cy', xyScaleY(y))
            .attr('visibility', 'visible');

        // Map x, y to theta1, theta2
        const theta2 = Math.acos((x * x + y * y - L1*L1 - L2*L2) / 2*L1*L2);
        theta1 = Math.atan2(y, x) - Math.atan2(L2*Math.sin(theta2), L1 + L2*Math.cos(theta2));

        const theta2_alt = -theta2;
        theta1_alt = Math.atan2(y, x) - Math.atan2(-L2*Math.sin(theta2), L1 + L2*Math.cos(theta2));
        
        if(theta1 < -Math.PI) {
            theta1 = theta1 + 2 * Math.PI;
        }
        if(theta1_alt > Math.PI) {
            theta1_alt = theta1_alt - 2 * Math.PI;
        }

        sol1Dot
            .attr('cx', thetaScaleX(theta1))
            .attr('cy', thetaScaleY(theta2));

        sol2Dot
            .attr('cx', thetaScaleX(theta1_alt))
            .attr('cy', thetaScaleY(theta2_alt));

        // Joint positions (1st solution)
        const joint1 = { x: L1 * Math.cos(theta1), y: L1 * Math.sin(theta1) };
        const endEffector = { x: joint1.x + L2 * Math.cos(theta1 + theta2), y: joint1.y + L2 * Math.sin(theta1 + theta2) };

        // Update linkages (1st solution)
        link1
            .attr('x1', xyScaleX(0))
            .attr('y1', xyScaleY(0))
            .attr('x2', xyScaleX(joint1.x))
            .attr('y2', xyScaleY(joint1.y));

        link2
            .attr('x1', xyScaleX(joint1.x))
            .attr('y1', xyScaleY(joint1.y))
            .attr('x2', xyScaleX(endEffector.x))
            .attr('y2', xyScaleY(endEffector.y));

        // Joint positions (1st solution)
        const joint1_alt = { x: L1 * Math.cos(theta1_alt), y: L1 * Math.sin(theta1_alt) };
        const endEffector_alt = { x: joint1_alt.x + L2 * Math.cos(theta1_alt + theta2_alt), y: joint1_alt.y + L2 * Math.sin(theta1_alt + theta2_alt) };

        // Update linkages (1st solution)
        link1_alt
            .attr('x1', xyScaleX(0))
            .attr('y1', xyScaleY(0))
            .attr('x2', xyScaleX(joint1_alt.x))
            .attr('y2', xyScaleY(joint1_alt.y));

        link2_alt
            .attr('x1', xyScaleX(joint1_alt.x))
            .attr('y1', xyScaleY(joint1_alt.y))
            .attr('x2', xyScaleX(endEffector_alt.x))
            .attr('y2', xyScaleY(endEffector_alt.y));

    } else {
        cursorDot.attr('visibility', 'hidden');
        link1.attr('visibility', 'hidden');
        link2.attr('visibility', 'hidden');
        link1_alt.attr('visibility', 'hidden');
        link2_alt.attr('visibility', 'hidden');
    }
});
