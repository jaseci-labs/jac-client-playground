import { Waypoints } from "lucide-react";
import React, {
  useState,
  useEffect,
  useMemo,
  useCallback,
  useRef,
} from "react";
import Graph from "react-graph-vis";

// Get graph options based on theme
function getGraphOptions(isDarkMode) {
  return {
    autoResize: true,
    nodes: {
      shape: "circle",
      size: 30,
      font: {
        size: 12,
        color: "#ffffff",
        face: "Arial",
      },
      borderWidth: 2,
      shadow: true,
      color: {
        background: "#3b82f6",
        border: isDarkMode ? "#4b5563" : "#374151",
        highlight: {
          background: "#f59e0b",
          border: "#f59e0b",
        },
      },
    },
    edges: {
      width: 2,
      color: {
        color: isDarkMode ? "#9ca3af" : "#6b7280",
        opacity: 0.8,
      },
      smooth: {
        type: "continuous",
        forceDirection: "none",
      },
      arrows: {
        to: {
          enabled: true,
          scaleFactor: 0.5,
        },
      },
      font: {
        size: 12,
        align: "top",
        color: isDarkMode ? "#e5e7eb" : "#374151",
        strokeWidth: isDarkMode ? 2 : 0,
        strokeColor: isDarkMode ? "#1f2937" : "#ffffff",
      },
    },
    physics: {
      enabled: true,
      solver: "forceAtlas2Based",
      forceAtlas2Based: {
        gravitationalConstant: -50,
        centralGravity: 0.01,
        springLength: 120,
        springConstant: 0.08,
        damping: 0.4,
        avoidOverlap: 0.8,
      },
      stabilization: {
        enabled: true,
        iterations: 200,
        updateInterval: 25,
        fit: true,
      },
    },
    interaction: {
      hover: true,
      tooltipDelay: 200,
      zoomView: true,
      dragView: true,
      dragNodes: true,
      hoverConnectedEdges: true,
    },
    layout: {
      improvedLayout: true,
      hierarchical: {
        enabled: false,
        sortMethod: "directed",
      },
    },
  };
}

// Get node color based on label/type
function getNodeColors(label, isRoot) {
  if (isRoot || label === "root") {
    return {
      background: "#ff7743",
      border: "#e05a2a",
    };
  }

  // Extract type from label like "Person(name='Alice', age=20)"
  const typeMatch = label.match(/^(\w+)\(/);
  if (typeMatch) {
    const type = typeMatch[1];
    // Generate color based on type name hash
    let hash = 0;
    for (let i = 0; i < type.length; i++) {
      hash = type.charCodeAt(i) + ((hash << 5) - hash);
    }
    const hue = Math.abs(hash % 360);
    return {
      background: `hsl(${hue}, 60%, 50%)`,
      border: `hsl(${hue}, 60%, 35%)`,
    };
  }

  return { background: "#3b82f6", border: "#374151" };
}

// Extract readable label from node label
function getDisplayLabel(label) {
  if (label === "root") return "root";

  // Extract name from label like "Person(name='Alice', age=20)"
  const nameMatch = label.match(/name='([^']+)'/);
  if (nameMatch) {
    return nameMatch[1];
  }

  // Extract type from label
  const typeMatch = label.match(/^(\w+)\(/);
  if (typeMatch) {
    return typeMatch[1];
  }

  return label;
}

// Extract edge label for display
function getEdgeLabel(label) {
  if (!label) return "";
  // Extract relationship value from label like "FamilyRelation(relationship_type='parent')"
  const match = label.match(/='(\w+)'/);
  if (match) {
    return match[1];
  }
  return "";
}

export function Visualizer({
  graphData,
  loading,
  error,
  showHeader,
  isDarkMode,
}) {
  const shouldShowHeader = showHeader !== false;
  const hasGraphData =
    graphData && graphData.nodes && graphData.nodes.length > 0;

  const [tooltip, setTooltip] = useState({
    visible: false,
    x: 0,
    y: 0,
    node: null,
  });

  // Network instance ref for resize handling
  const networkRef = useRef(null);
  const containerRef = useRef(null);

  // Get theme-aware graph options
  const graphOptions = useMemo(() => getGraphOptions(isDarkMode), [isDarkMode]);

  // Set default grab cursor on canvas after component mounts
  useEffect(() => {
    const timer = setTimeout(() => {
      const canvas = document.querySelector("canvas");
      if (canvas) {
        canvas.style.cursor = "grab";
      }
    }, 100);

    return () => clearTimeout(timer);
  }, [hasGraphData]);

  // Handle container resize
  useEffect(() => {
    if (!containerRef.current || !networkRef.current) return;

    const resizeObserver = new ResizeObserver(() => {
      if (networkRef.current) {
        networkRef.current.redraw();
        networkRef.current.fit({
          animation: {
            duration: 300,
            easingFunction: "easeInOutQuad",
          },
        });
      }
    });

    resizeObserver.observe(containerRef.current);

    return () => resizeObserver.disconnect();
  }, [hasGraphData]);

  // Transform data for react-graph-vis
  const visGraph = useMemo(() => {
    if (!hasGraphData) return null;

    const nodes = graphData.nodes.map((node) => {
      const isRoot = node.label === "root";
      const colors = getNodeColors(node.label, isRoot);

      return {
        id: node.id.toString(),
        label: getDisplayLabel(node.label),
        color: {
          background: colors.background,
          border: colors.border,
          highlight: {
            background: "#f59e0b",
            border: "#f59e0b",
          },
        },
        title: node.label, // Full label as tooltip
        font: {
          color: "#ffffff",
        },
      };
    });

    const edges = graphData.edges.map((edge, index) => ({
      id: `edge_${index}`,
      from: edge.from.toString(),
      to: edge.to.toString(),
      label: getEdgeLabel(edge.label),
      title: edge.label || "connection",
      arrows: "to",
    }));

    return { nodes, edges };
  }, [graphData, hasGraphData]);

  // Find original node data by id
  const findNodeById = useCallback(
    (nodeId) => {
      if (!graphData || !graphData.nodes) return null;
      return graphData.nodes.find((n) => n.id.toString() === nodeId);
    },
    [graphData]
  );

  // Event handlers
  const events = useMemo(
    () => ({
      select: ({ nodes, edges }) => {
        console.log("Selected nodes:", nodes);
        console.log("Selected edges:", edges);
      },
      hoverNode: (event) => {
        const canvas = event.event?.target;
        if (canvas) {
          canvas.style.cursor = "pointer";
        }

        const nodeId = event.node;
        const node = findNodeById(nodeId);
        if (node) {
          setTooltip({
            visible: true,
            x: event.pointer.DOM.x,
            y: event.pointer.DOM.y,
            node: node,
          });
        }
      },
      blurNode: (event) => {
        const canvas = event.event?.target;
        if (canvas) {
          canvas.style.cursor = "grab";
        }
        setTooltip({ visible: false, x: 0, y: 0, node: null });
      },
      hoverEdge: (event) => {
        const canvas = event.event?.target;
        if (canvas) {
          canvas.style.cursor = "grab";
        }
      },
      dragStart: (event) => {
        const canvas = event.event?.target;
        if (canvas) {
          canvas.style.cursor = "grabbing";
        }
      },
      dragEnd: (event) => {
        const canvas = event.event?.target;
        if (canvas) {
          canvas.style.cursor = "grab";
        }
      },
      click: (event) => {
        if (event.nodes.length === 0) {
          const canvas = event.event?.target;
          if (canvas) {
            canvas.style.cursor = "grab";
          }
        }
      },
      stabilized: () => {
        // Fit graph to view after stabilization
        if (networkRef.current) {
          networkRef.current.fit({
            animation: {
              duration: 300,
              easingFunction: "easeInOutQuad",
            },
          });
        }
      },
    }),
    [findNodeById]
  );

  // Callback to get network instance
  const getNetwork = useCallback((network) => {
    networkRef.current = network;
  }, []);

  // Stable key to prevent unnecessary re-mounts
  const graphKey = useMemo(() => {
    if (!hasGraphData) return "empty";
    return `graph-${graphData.nodes.length}-${graphData.edges.length}-${
      isDarkMode ? "dark" : "light"
    }`;
  }, [hasGraphData, graphData, isDarkMode]);

  return (
    <div className="h-full flex flex-col">
      {shouldShowHeader && (
        <div className="flex items-center gap-2 px-3 py-2 border-b border-border bg-background">
          <div className="text-xs text-text-secondary">Graph Visualizer</div>
          <div className="flex-1" />
          <div className="text-xs text-text-secondary">
            {hasGraphData
              ? `${graphData.nodes.length} nodes, ${graphData.edges.length} edges`
              : "output"}
          </div>
        </div>
      )}

      {hasGraphData ? (
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
              height: "100%",
              width: "100%",
              position: "absolute",
              top: 0,
              left: 0,
              cursor: "grab",
            }}
          />

          {/* Tooltip */}
          {tooltip.visible && tooltip.node && (
            <div
              className="absolute z-50 bg-surface border border-border rounded-lg shadow-xl p-3 max-w-xs pointer-events-none"
              style={{
                left: Math.min(tooltip.x + 10, window.innerWidth - 280),
                top: tooltip.y - 10,
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
      ) : (
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
