defmodule Orderflow.GenServerTest do
  use Orderflow.DataCase

  alias Orderflow.Metrics.Collector
  alias Orderflow.Notifications.OrderNotifier
  alias Orderflow.Alerts.Scheduler

  describe "Metrics.Collector" do
    test "returns metrics" do
      metrics = Collector.get_dashboard_metrics()

      assert is_map(metrics)
      assert Map.has_key?(metrics, :orders_today)
      assert Map.has_key?(metrics, :revenue_today)
      assert Map.has_key?(metrics, :active_orders)
      assert Map.has_key?(metrics, :orders_by_status)
    end

    test "refresh_metrics updates cache" do
      # Get initial metrics
      _initial = Collector.get_dashboard_metrics()

      # Refresh
      Collector.refresh_metrics()

      # Allow time for refresh
      Process.sleep(100)

      refreshed = Collector.get_dashboard_metrics()
      assert is_map(refreshed)
    end
  end

  describe "OrderNotifier" do
    test "process is alive" do
      pid = Process.whereis(OrderNotifier)
      assert pid != nil
      assert Process.alive?(pid)
    end
  end

  describe "Alerts.Scheduler" do
    test "process is alive" do
      pid = Process.whereis(Scheduler)
      assert pid != nil
      assert Process.alive?(pid)
    end
  end
end
