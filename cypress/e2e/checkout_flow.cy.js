describe('Checkout Flow', () => {
  beforeEach(() => {
    // Reset any test data and set up initial state
    cy.request('POST', `${Cypress.env('apiUrl')}/test/reset`)
    cy.visit('/')
  })

  it('completes a full checkout flow as a guest user', () => {
    // Add a product to cart
    cy.get('[data-testid="product-card"]').first().click()
    cy.get('[data-testid="add-to-cart"]').click()
    cy.get('[data-testid="cart-count"]').should('have.text', '1')

    // Go to checkout
    cy.get('[data-testid="checkout-button"]').click()

    // Fill in shipping information
    cy.get('[data-testid="shipping-form"]').within(() => {
      cy.get('input[name="email"]').type('test@example.com')
      cy.get('input[name="name"]').type('John Doe')
      cy.get('input[name="street"]').type('123 Main St')
      cy.get('input[name="city"]').type('Los Angeles')
      cy.get('input[name="state"]').type('CA')
      cy.get('input[name="postal_code"]').type('90210')
      cy.get('select[name="country"]').select('US')
    })
    cy.get('[data-testid="continue-to-payment"]').click()

    // Fill in payment information
    cy.get('[data-testid="payment-form"]').within(() => {
      // Use Stripe test card
      cy.get('input[name="cardNumber"]').type('4242424242424242')
      cy.get('input[name="cardExpiry"]').type('1230')
      cy.get('input[name="cardCvc"]').type('123')
    })
    cy.get('[data-testid="submit-payment"]').click()

    // Verify order confirmation
    cy.url().should('include', '/orders/confirmation')
    cy.get('[data-testid="order-confirmation"]').should('be.visible')
    cy.get('[data-testid="order-number"]').should('exist')

    // Verify email was sent
    cy.mailhog()
      .then(emails => {
        const confirmationEmail = emails.find(
          email => email.subject.includes('Order Confirmation')
        )
        expect(confirmationEmail).to.exist
      })
  })

  it('completes checkout as a logged-in user', () => {
    // Create and log in as a user
    cy.request('POST', `${Cypress.env('apiUrl')}/users`, {
      user: {
        email: 'user@example.com',
        password: 'password123',
        password_confirmation: 'password123'
      }
    })

    cy.request('POST', `${Cypress.env('apiUrl')}/users/sign_in`, {
      user: {
        email: 'user@example.com',
        password: 'password123'
      }
    }).then((response) => {
      window.localStorage.setItem('authToken', response.body.token)
    })

    cy.visit('/')

    // Add product and complete checkout
    cy.get('[data-testid="product-card"]').first().click()
    cy.get('[data-testid="add-to-cart"]').click()
    cy.get('[data-testid="checkout-button"]').click()

    // Verify saved addresses are available
    cy.get('[data-testid="saved-addresses"]').should('exist')

    // Complete checkout with saved information
    cy.get('[data-testid="continue-to-payment"]').click()
    cy.get('[data-testid="payment-form"]').within(() => {
      cy.get('input[name="cardNumber"]').type('4242424242424242')
      cy.get('input[name="cardExpiry"]').type('1230')
      cy.get('input[name="cardCvc"]').type('123')
    })
    cy.get('[data-testid="submit-payment"]').click()

    // Verify order appears in user's order history
    cy.visit('/orders')
    cy.get('[data-testid="order-list"]').should('exist')
    cy.get('[data-testid="order-item"]').should('have.length.at.least', 1)
  })
}) 