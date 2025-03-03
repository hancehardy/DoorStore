class OrderMailer < ApplicationMailer
  def order_updated(order)
    @order = order
    @user = order.user
    mail(
      to: @user.email,
      subject: "Your Order ##{order.id} Has Been Updated"
    )
  end

  def refund_processed(order)
    @order = order
    @user = order.user
    @refund_amount = order.refund_amount
    mail(
      to: @user.email,
      subject: "Refund Processed for Order ##{order.id}"
    )
  end

  def order_cancelled(order)
    @order = order
    @user = order.user
    mail(
      to: @user.email,
      subject: "Order ##{order.id} Has Been Cancelled"
    )
  end
end
