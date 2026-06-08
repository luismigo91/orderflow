defmodule OrderflowWeb.Api.ApiDocsController do
  use OrderflowWeb, :controller

  def index(conn, _params) do
    json(conn, %{
      openapi: "3.0.0",
      info: %{
        title: "OrderFlow API",
        version: "1.0.0",
        description: "REST API for OrderFlow - Restaurant Order Management System"
      },
      servers: [
        %{url: "http://localhost:4000/api/v1", description: "Local Development"}
      ],
      paths: %{
        "/sessions" => %{
          post: %{
            summary: "Authenticate user",
            requestBody: %{
              content: %{
                "application/json" => %{
                  schema: %{
                    type: "object",
                    properties: %{
                      email: %{type: "string"},
                      password: %{type: "string"}
                    }
                  }
                }
              }
            },
            responses: %{
              "200" => %{description: "Authentication successful"},
              "401" => %{description: "Invalid credentials"}
            }
          }
        },
        "/orders" => %{
          get: %{
            summary: "List orders",
            parameters: [
              %{name: "cursor", in: "query", schema: %{type: "integer"}},
              %{name: "limit", in: "query", schema: %{type: "integer", default: 20}}
            ],
            responses: %{
              "200" => %{description: "List of orders"}
            }
          },
          post: %{
            summary: "Create order",
            requestBody: %{
              content: %{
                "application/json" => %{
                  schema: %{
                    type: "object",
                    properties: %{
                      customer_name: %{type: "string"},
                      customer_phone: %{type: "string"},
                      items: %{type: "array"}
                    }
                  }
                }
              }
            },
            responses: %{
              "201" => %{description: "Order created"}
            }
          }
        },
        "/orders/{id}" => %{
          get: %{
            summary: "Get order by ID",
            parameters: [
              %{name: "id", in: "path", required: true, schema: %{type: "integer"}}
            ],
            responses: %{
              "200" => %{description: "Order details"}
            }
          }
        },
        "/orders/{id}/status" => %{
          patch: %{
            summary: "Update order status",
            parameters: [
              %{name: "id", in: "path", required: true, schema: %{type: "integer"}}
            ],
            requestBody: %{
              content: %{
                "application/json" => %{
                  schema: %{
                    type: "object",
                    properties: %{
                      status: %{
                        type: "string",
                        enum: [
                          "pending",
                          "confirmed",
                          "cooking",
                          "ready",
                          "delivering",
                          "delivered",
                          "cancelled"
                        ]
                      }
                    }
                  }
                }
              }
            },
            responses: %{
              "200" => %{description: "Status updated"}
            }
          }
        },
        "/products" => %{
          get: %{
            summary: "List products",
            responses: %{
              "200" => %{description: "List of products"}
            }
          }
        },
        "/products/search" => %{
          get: %{
            summary: "Search products",
            parameters: [
              %{name: "q", in: "query", required: true, schema: %{type: "string"}}
            ],
            responses: %{
              "200" => %{description: "Search results"}
            }
          }
        },
        "/health" => %{
          get: %{
            summary: "Health check",
            responses: %{
              "200" => %{description: "System healthy"},
              "503" => %{description: "System unhealthy"}
            }
          }
        }
      },
      components: %{
        securitySchemes: %{
          bearerAuth: %{
            type: "http",
            scheme: "bearer",
            bearerFormat: "JWT"
          }
        }
      },
      security: [
        %{bearerAuth: []}
      ]
    })
  end
end
