# Visualizer component - Graph visualization using react-graph-vis
# Full Jac implementation

cl import from react { useState, useEffect, useMemo, useCallback }
cl import from "lucide-react" { Waypoints }
cl import from "react-graph-vis" { default as Graph }

# Get graph options based on theme
cl def getGraphOptions(isDarkMode: bool) -> dict {
    return {
        "nodes": {
            "shape": "circle",
            "size": 30,
            "font": {
                "size": 12,
                "color": "#ffffff",
                "face": "Arial"
            },
            "borderWidth": 2,
            "shadow": true,
            "color": {
                "background": "#3b82f6",
                "border": isDarkMode and "#4b5563" or "#374151",
                "highlight": {
                    "background": "#f59e0b",
                    "border": "#f59e0b"
                }
            }
        },
        "edges": {
            "width": 2,
            "color": {
                "color": isDarkMode and "#6b7280" or "#9ca3af",
                "opacity": 0.8
            },
            "smooth": {
                "type": "continuous",
                "forceDirection": "none"
            },
            "arrows": {
                "to": {
                    "enabled": true,
                    "scaleFactor": 0.5
                }
            },
            "font": {
                "size": 10,
                "align": "middle",
                "color": isDarkMode and "#9ca3af" or "#666"
            }
        },
        "physics": {
            "enabled": true,
            "solver": "forceAtlas2Based",
            "forceAtlas2Based": {
                "gravitationalConstant": -50,
                "centralGravity": 0.01,
                "springLength": 100,
                "springConstant": 0.08,
                "damping": 0.4,
                "avoidOverlap": 0.5
            },
            "stabilization": {
                "enabled": true,
                "iterations": 1000,
                "updateInterval": 100
            }
        },
        "interaction": {
            "hover": true,
            "tooltipDelay": 200,
            "zoomView": true,
            "dragView": true,
            "dragNodes": true,
            "hoverConnectedEdges": true
        },
        "layout": {
            "improvedLayout": true,
            "hierarchical": {
                "enabled": false,
                "sortMethod": "directed"
            }
        }
    };
}

# Get node color based on label/type
cl def getNodeColors(label: str, isRoot: bool) -> dict {
    if isRoot or label == "root" {
        return {
            "background": "#ff7743",
            "border": "#e05a2a"
        };
    }
    
    # Extract type from label like "Person(name='Alice', age=20)"
    typeMatch = label.match(r"^(\w+)\(");
    if typeMatch {
        nodeType = typeMatch[1];
        # Generate color based on type name hash
        hash = 0;
        for i in range(len(nodeType)) {
            hash = nodeType.charCodeAt(i) + ((hash << 5) - hash);
        }
        hue = Math.abs(hash % 360);
        return {
            "background": f"hsl({hue}, 60%, 50%)",
            "border": f"hsl({hue}, 60%, 35%)"
        };
    }
    
    return { "background": "#3b82f6", "border": "#374151" };
}

# Extract readable label from node label
cl def getDisplayLabel(label: str) -> str {
    if label == "root" {
        return "root";
    }
    
    # Extract name from label like "Person(name='Alice', age=20)"
    nameMatch = label.match(r"name='([^']+)'");
    if nameMatch {
        return nameMatch[1];
    }
    
    # Extract type from label
    typeMatch = label.match(r"^(\w+)\(");
    if typeMatch {
        return typeMatch[1];
    }
    
    return label;
}

# Extract edge label for display
cl def getEdgeLabel(label: str) -> str {
    if not label {
        return "";
    }
    # Extract relationship value from label like "FamilyRelation(relationship_type='parent')"
    match = label.match(r"='(\w+)'");
    if match {
        return match[1];
    }
    return "";
}

cl {
    def Visualizer(props: dict) -> any {
        graphData = props.graphData;
        loading = props.loading;
        error = props.error;
        showHeader = props.showHeader;
        isDarkMode = props.isDarkMode or false;
        
        shouldShowHeader = showHeader != false;
        hasGraphData = graphData and graphData.nodes and graphData.nodes.length > 0;
        
        # Tooltip state
        [tooltip, setTooltip] = useState({
            "visible": false,
            "x": 0,
            "y": 0,
            "node": None
        });
        
        # Get theme-aware graph options
        graphOptions = useMemo(
            lambda -> dict { return getGraphOptions(isDarkMode); },
            [isDarkMode]
        );
        
        # Set default grab cursor on canvas after component mounts
        useEffect(
            lambda -> any {
                timer = setTimeout(
                    lambda -> None {
                        canvas = document.querySelector("canvas");
                        if canvas {
                            canvas.style.cursor = "grab";
                        }
                    },
                    100
                );
                return lambda -> None { clearTimeout(timer); };
            },
            [hasGraphData]
        );
        
        # Transform data for react-graph-vis
        visGraph = useMemo(
            lambda -> any {
                if not hasGraphData {
                    return None;
                }
                
                nodes = graphData.nodes.map(lambda node -> dict {
                    isRoot = node.label == "root";
                    colors = getNodeColors(node.label, isRoot);
                    
                    return {
                        "id": String(node.id),
                        "label": getDisplayLabel(node.label),
                        "color": {
                            "background": colors.background,
                            "border": colors.border,
                            "highlight": {
                                "background": "#f59e0b",
                                "border": "#f59e0b"
                            }
                        },
                        "title": node.label,
                        "font": {
                            "color": "#ffffff"
                        }
                    };
                });
                
                edges = graphData.edges.map(lambda (edge, index) -> dict {
                    return {
                        "id": f"edge_{index}",
                        "from": (edge.from).toString(),
                        "to": (edge.to).toString(),
                        "label": getEdgeLabel(edge.label),
                        "title": edge.label or "connection",
                        "arrows": "to"
                    };
                });
                
                return { "nodes": nodes, "edges": edges };
            },
            [graphData, hasGraphData]
        );
        
        # Find original node data by id
        findNodeById = useCallback(
            lambda nodeId -> any {
                if not graphData or not graphData.nodes {
                    return None;
                }
                return graphData.nodes.find(lambda n -> bool { return String(n.id) == nodeId; });
            },
            [graphData]
        );
        
        # Event handlers
        events = useMemo(
            lambda -> dict {
                return {
                    "select": lambda event -> None {
                        console.log("Selected nodes:", event.nodes);
                        console.log("Selected edges:", event.edges);
                    },
                    "hoverNode": lambda event -> None {
                        canvas = event.event?.target;
                        if canvas {
                            canvas.style.cursor = "pointer";
                        }
                        
                        nodeId = event.node;
                        node = findNodeById(nodeId);
                        if node {
                            setTooltip({
                                "visible": true,
                                "x": event.pointer.DOM.x,
                                "y": event.pointer.DOM.y,
                                "node": node
                            });
                        }
                    },
                    "blurNode": lambda event -> None {
                        canvas = event.event?.target;
                        if canvas {
                            canvas.style.cursor = "grab";
                        }
                        setTooltip({ "visible": false, "x": 0, "y": 0, "node": None });
                    },
                    "hoverEdge": lambda event -> None {
                        canvas = event.event?.target;
                        if canvas {
                            canvas.style.cursor = "grab";
                        }
                    },
                    "dragStart": lambda event -> None {
                        canvas = event.event?.target;
                        if canvas {
                            canvas.style.cursor = "grabbing";
                        }
                    },
                    "dragEnd": lambda event -> None {
                        canvas = event.event?.target;
                        if canvas {
                            canvas.style.cursor = "grab";
                        }
                    },
                    "click": lambda event -> None {
                        if event.nodes.length == 0 {
                            canvas = event.event?.target;
                            if canvas {
                                canvas.style.cursor = "grab";
                            }
                        }
                    }
                };
            },
            [findNodeById]
        );
        
        # Stable key to prevent unnecessary re-mounts
        graphKey = useMemo(
            lambda -> str {
                if not hasGraphData {
                    return "empty";
                }
                return f"graph-{graphData.nodes.length}-{graphData.edges.length}-{isDarkMode and 'dark' or 'light'}";
            },
            [hasGraphData, graphData, isDarkMode]
        );
        
        return (
            <div className="h-full flex flex-col">
                {shouldShowHeader and (
                    <div className="flex items-center gap-2 px-3 py-2 border-b border-border bg-background">
                        <div className="text-xs text-text-secondary">Graph Visualizer</div>
                        <div className="flex-1" />
                        <div className="text-xs text-text-secondary">
                            {hasGraphData
                                and f"{graphData.nodes.length} nodes, {graphData.edges.length} edges"
                                or "output"}
                        </div>
                    </div>
                )}
                
                {hasGraphData and (
                    <div className="flex-1 relative overflow-hidden bg-surface">
                        <Graph
                            key={graphKey}
                            graph={visGraph}
                            options={graphOptions}
                            events={events}
                            style={{
                                "height": "100%",
                                "width": "100%",
                                "position": "absolute",
                                "top": 0,
                                "left": 0,
                                "cursor": "grab"
                            }}
                        />
                        
                        {tooltip.visible and tooltip.node and (
                            <div
                                className="absolute z-50 bg-surface border border-border rounded-lg shadow-xl p-3 max-w-xs pointer-events-none"
                                style={{
                                    "left": Math.min(tooltip.x + 10, window.innerWidth - 280),
                                    "top": tooltip.y - 10
                                }}
                            >
                                <div className="space-y-2">
                                    <div className="border-b border-border pb-2">
                                        <h3 className="font-semibold text-text text-sm">
                                            {getDisplayLabel(tooltip.node.label)}
                                        </h3>
                                        <p className="text-xs text-text-secondary font-mono break-all">
                                            {tooltip.node.label}
                                        </p>
                                    </div>
                                    <div className="text-xs text-text-secondary">
                                        ID: {tooltip.node.id}
                                    </div>
                                </div>
                            </div>
                        )}
                    </div>
                )}
                
                {(not hasGraphData) and (
                    <div className="flex-1 flex items-center justify-center bg-surface">
                        <div className="text-text-secondary text-center px-6 flex flex-col items-center justify-center">
                            <div className="mb-3 text-3xl text-center">
                                <Waypoints className="w-8 h-8" />
                            </div>
                            <div className="font-medium">Jac Graph Visualizer</div>
                            <div className="text-sm text-text-secondary mt-2">
                                Execute your Jac code to see the graph visualization.
                            </div>
                        </div>
                    </div>
                )}
            </div>
        );
    }
}
