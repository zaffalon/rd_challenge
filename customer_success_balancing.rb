require 'minitest/autorun'
require 'timeout'
class CustomerSuccessBalancing
  def initialize(customer_success, customers, customer_success_away)
    @customer_success = customer_success
    @customers = customers
    @customer_success_away = customer_success_away
  end

  # Returns the id of the CustomerSuccess with the most customers
  def execute
    sorted_customer_sucess = sort_only_activated_customer_sucess
    sorted_customers = @customers.sort_by{|cus| cus[:score]}
    
    maximum_count = 0
    maximum_ids = []
    size_of_customers = sorted_customers.size 

    index_of_customers = 0
    sorted_customer_sucess.each do |customer_success|
      customer_sucess_score = customer_success[:score] 
      auxiliary_count = 0

      while index_of_customers < size_of_customers do
        customer_score = sorted_customers[index_of_customers][:score]
        index_of_customers += 1
        customer_score <= customer_sucess_score ? (next auxiliary_count += 1) : break
      end

      if auxiliary_count > maximum_count
        maximum_count = auxiliary_count 
        maximum_ids = [customer_success[:id]]
      elsif auxiliary_count == maximum_count
        maximum_ids << customer_success[:id]
      end

    end

    maximum_ids.size > 1 ? 0 : maximum_ids.first
  end

  def customer_success_away_to_hash(arr)
    out = {}
    arr.each{|a| out[a] = true} 
    out
  end

  def sort_only_activated_customer_sucess
    customer_success_away_hash = customer_success_away_to_hash(@customer_success_away)
    active_customer_sucess = @customer_success.reject{|cs| customer_success_away_hash[cs[:id]] == true }
    sorted_custumer_sucess = active_customer_sucess.sort_by{|cs| cs[:score]}
  end
end

class CustomerSuccessBalancingTests < Minitest::Test
  def test_scenario_one
    css = [{ id: 1, score: 60 }, { id: 2, score: 20 }, { id: 3, score: 95 }, { id: 4, score: 75 }]
    customers = [{ id: 1, score: 90 }, { id: 2, score: 20 }, { id: 3, score: 70 }, { id: 4, score: 40 }, { id: 5, score: 60 }, { id: 6, score: 10}]

    balancer = CustomerSuccessBalancing.new(css, customers, [2, 4])
    assert_equal 1, balancer.execute
  end

  def test_scenario_two
    css = array_to_map([11, 21, 31, 3, 4, 5])
    customers = array_to_map( [10, 10, 10, 20, 20, 30, 30, 30, 20, 60])
    balancer = CustomerSuccessBalancing.new(css, customers, [])
    assert_equal 0, balancer.execute
  end

  def test_scenario_three
    customer_success = (1..999).to_a
    customers = Array.new(10000, 998)

    balancer = CustomerSuccessBalancing.new(array_to_map(customer_success), array_to_map(customers), [999])

    result = Timeout.timeout(1.0) { balancer.execute }
    assert_equal 998, result
  end

  def test_scenario_four
    balancer = CustomerSuccessBalancing.new(array_to_map([1, 2, 3, 4, 5, 6]), array_to_map([10, 10, 10, 20, 20, 30, 30, 30, 20, 60]), [])
    assert_equal 0, balancer.execute
  end

  def test_scenario_five
    balancer = CustomerSuccessBalancing.new(array_to_map([100, 2, 3, 3, 4, 5]), array_to_map([10, 10, 10, 20, 20, 30, 30, 30, 20, 60]), [])
    assert_equal 1, balancer.execute
  end

  def test_scenario_six
    balancer = CustomerSuccessBalancing.new(array_to_map([100, 99, 88, 3, 4, 5]), array_to_map([10, 10, 10, 20, 20, 30, 30, 30, 20, 60]), [1, 3, 2])
    assert_equal 0, balancer.execute
  end

  def test_scenario_seven
    balancer = CustomerSuccessBalancing.new(array_to_map([100, 99, 88, 3, 4, 5]), array_to_map([10, 10, 10, 20, 20, 30, 30, 30, 20, 60]), [4, 5, 6])
    assert_equal 3, balancer.execute
  end

  def array_to_map(arr)
    out = []
    arr.each_with_index { |score, index| out.push({ id: index + 1, score: score }) }
    out
  end
end


Minitest.run