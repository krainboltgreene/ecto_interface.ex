defmodule EctoInterface.Factory do
  @moduledoc false
  use ExMachina.Ecto, repo: EctoInterface.TestRepo

  def customer_factory do
    %EctoInterfaceContext.Customer{
      name: "Bob",
      internal_uuid: Ecto.UUID.generate(),
      active: true
    }
  end

  def address_factory do
    %EctoInterfaceContext.Address{
      city: "City name",
      customer: build(:customer)
    }
  end

  def payment_factory do
    %EctoInterfaceContext.Payment{
      description: "Skittles",
      charged_at: DateTime.utc_now(),
      # +10 so it doesn't mess with low amounts we want to order on.
      amount: :rand.uniform(100) + 10,
      status: "success",
      customer: build(:customer)
    }
  end
end
