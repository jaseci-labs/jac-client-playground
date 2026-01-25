import from "lucide-react" { Waypoints }
import from "react" { useState, useEffect, useMemo, useCallback, useRef }
import from "react-graph-vis" { * as GraphModule }

glob Graph: GraphModule = GraphModule.default;

# Get graph options based on theme
def getGraphOptions(isDarkMode: bool) -> dict {
    return {
        "autoResize": true,
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
                "color": isDarkMode and "#9ca3af" or "#6b7280",
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
                "size": 12,
                "align": "top",
                "color": isDarkMode and "#e5e7eb" or "#374151",
                "strokeWidth": isDarkMode and 2 or 0,
                "strokeColor": isDarkMode and "#1f2937" or "#ffffff"
            }
        },
        "physics": {
            "enabled": true,
            "solver": "forceAtlas2Based",
            "forceAtlas2Based": {
                "gravitationalConstant": -50,
                "centralGravity": 0.01,
                "springLength": 120,
                "springConstant": 0.08,
                "damping": 0.4,
                "avoidOverlap": 0.8
            },
            "stabilization": {
                "enabled": true,
                "iterations": 200,
                "updateInterval": 25,
                "fit": true
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
def getNodeColors(label: str, isRoot: bool) -> dict {
    if isRoot or label == "root" {
        return {
            "background": "#ff7743",
            "border": "#e05a2a"
        };
    }

    # Extract type from label like "Person(name='Alice', age=20)"
    # Use character class [a-zA-Z0-9_] instead of \w to avoid escaping issues
    typePattern = Reflect.construct(RegExp, ['^([a-zA-Z0-9_]+)[(]']);
    typeMatch = label.match(typePattern);
    if typeMatch {
        nodeType = typeMatch[1];
        # Generate color based on type name hash using Array.reduce
        hashValue = nodeType.split('').reduce(
            lambda acc: int, char: str -> int {
                return char.charCodeAt(0) + ((acc << 5) - acc);
            },
            0
        );
        hue = Math.abs(hashValue % 360);
        return {
            "background": f"hsl({hue}, 60%, 50%)",
            "border": f"hsl({hue}, 60%, 35%)"
        };
    }

    return { "background": "#3b82f6", "border": "#374151" };
}

# Extract readable label from node label
def getDisplayLabel(label: str) -> str {
    if label == "root" {
        return "root";
    }

    # Extract name from label like "Person(name='Alice', age=20)"
    namePattern = Reflect.construct(RegExp, ["name='([^']+)'"]);
    nameMatch = label.match(namePattern);
    if nameMatch {
        return nameMatch[1];
    }

    # Extract type from label
    typePattern = Reflect.construct(RegExp, ['^([a-zA-Z0-9_]+)[(]']);
    typeMatch = label.match(typePattern);
    if typeMatch {
        return typeMatch[1];
    }

    return label;
}

# Extract edge label for display
def getEdgeLabel(label: str) -> str {
    if not label {
        return "";
    }
    # Extract relationship value from label like "FamilyRelation(relationship_type='parent')"
    edgePattern = Reflect.construct(RegExp, ["='([a-zA-Z0-9_]+)'"]);
    edgeMatch = label.match(edgePattern);
    if edgeMatch {
        return edgeMatch[1];
    }
    return "";
}

def: pub Visualizer(props: dict) -> any {
    # Props extraction
    graphData = props.graphData;
    loading = props.loading or false;
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

    # Network instance ref for resize handling
    networkRef = useRef(None);
    containerRef = useRef(None);

    # Get theme-aware graph options
    graphOptions = useMemo(lambda -> dict {
        return getGraphOptions(isDarkMode);
    }, [isDarkMode]);

    # Set default grab cursor on canvas after component mounts
    useEffect(lambda -> any {
        timer = setTimeout(lambda -> None {
            canvas = document.querySelector("canvas");
            if canvas {
                canvas.style.cursor = "grab";
            }
        }, 100);

        return lambda -> None {
            clearTimeout(timer);
        };
    }, [hasGraphData]);

    # Handle container resize
    useEffect(lambda -> any {
        if not containerRef.current or not networkRef.current {
            return;
        }

        resizeObserver = Reflect.construct(ResizeObserver, [lambda -> None {
            if networkRef.current {
                networkRef.current.redraw();
                networkRef.current.fit({
                    "animation": {
                        "duration": 300,
                        "easingFunction": "easeInOutQuad"
                    }
                });
            }
        }]);

        resizeObserver.observe(containerRef.current);

        return lambda -> None {
            resizeObserver.disconnect();
        };
    }, [hasGraphData]);

    # Transform data for react-graph-vis
    visGraph = useMemo(lambda -> any {
        if not hasGraphData {
            return None;
        }

        nodes = graphData.nodes.map(lambda n: any -> dict {
            isRoot = n.label == "root";
            colors = getNodeColors(n.label, isRoot);

            return {
                "id": n.id.toString(),
                "label": getDisplayLabel(n.label),
                "color": {
                    "background": colors.background,
                    "border": colors.border,
                    "highlight": {
                        "background": "#f59e0b",
                        "border": "#f59e0b"
                    }
                },
                "title": n.label,
                "font": {
                    "color": "#ffffff"
                }
            };
        });

        edges = graphData.edges.map(lambda edge: any, index: int -> dict {
            return {
                "id": f"edge_{index}",
                "from": edge.from.toString(),
                "to": edge.to.toString(),
                "label": getEdgeLabel(edge.label),
                "title": edge.label or "connection",
                "arrows": "to"
            };
        });

        return { "nodes": nodes, "edges": edges };
    }, [graphData, hasGraphData]);

    # Find original node data by id
    findNodeById = useCallback(lambda nodeId: str -> any {
        if not graphData or not graphData.nodes {
            return None;
        }
        return graphData.nodes.find(lambda n: any -> bool {
            return n.id.toString() == nodeId;
        });
    }, [graphData]);

    # Event handlers
    events = useMemo(lambda -> dict {
        return {
            "select": lambda params: dict -> None {
                console.log("Selected nodes:", params.nodes);
                console.log("Selected edges:", params.edges);
            },
            "hoverNode": lambda event: any -> None {
                canvas = event.event?.target;
                if canvas {
                    canvas.style.cursor = "pointer";
                }

                nodeId = event.node;
                foundNode = findNodeById(nodeId);
                if foundNode {
                    setTooltip({
                        "visible": true,
                        "x": event.pointer.DOM.x,
                        "y": event.pointer.DOM.y,
                        "node": foundNode
                    });
                }
            },
            "blurNode": lambda event: any -> None {
                canvas = event.event?.target;
                if canvas {
                    canvas.style.cursor = "grab";
                }
                setTooltip({ "visible": false, "x": 0, "y": 0, "node": None });
            },
            "hoverEdge": lambda event: any -> None {
                canvas = event.event?.target;
                if canvas {
                    canvas.style.cursor = "grab";
                }
            },
            "dragStart": lambda event: any -> None {
                canvas = event.event?.target;
                if canvas {
                    canvas.style.cursor = "grabbing";
                }
            },
            "dragEnd": lambda event: any -> None {
                canvas = event.event?.target;
                if canvas {
                    canvas.style.cursor = "grab";
                }
            },
            "click": lambda event: any -> None {
                if event.nodes.length == 0 {
                    canvas = event.event?.target;
                    if canvas {
                        canvas.style.cursor = "grab";
                    }
                }
            },
            "stabilized": lambda -> None {
                # Fit graph to view after stabilization
                if networkRef.current {
                    networkRef.current.fit({
                        "animation": {
                            "duration": 300,
                            "easingFunction": "easeInOutQuad"
                        }
                    });
                }
            }
        };
    }, [findNodeById]);

    # Callback to get network instance
    getNetwork = useCallback(lambda network: any -> None {
        networkRef.current = network;
    }, []);

    # Stable key to prevent unnecessary re-mounts
    graphKey = useMemo(lambda -> str {
        if not hasGraphData {
            return "empty";
        }
        themeStr = isDarkMode and "dark" or "light";
        return f"graph-{graphData.nodes.length}-{graphData.edges.length}-{themeStr}";
    }, [hasGraphData, graphData, isDarkMode]);

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
                <div
                    ref={containerRef}
                    className="flex-1 relative overflow-hidden bg-surface"
                >
                    <Graph
                        key={graphKey}
                        graph={visGraph}
                        options={graphOptions}
                        events={events}
                        getNetwork={getNetwork}
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
