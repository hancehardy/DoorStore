describe('Checkout Flow', () => {
  beforeEach(() => {
    // Reset any test data and authenticate
    cy.request('POST', `${Cypress.env('apiUrl')}/test/reset`)
    cy.request('POST', `${Cypress.env('apiUrl')}/auth`, {
      email: 'test@example.com',
      password: 'password123'
    }).then((response) => {
      window.localStorage.setItem('authToken', response.body.token)
    })
  })

  it('completes a successful checkout', () => {
    // Visit the products page
    cy.visit('/products')
    
    // Add a product to cart
    cy.get('[data-testid="product-card"]').first().within(() => {
      cy.get('[data-testid="add-to-cart"]').click()
    })

    // Verify cart update
    cy.get('[data-testid="cart-count"]').should('have.text', '1')

    // Go to cart
    cy.get('[data-testid="cart-icon"]').click()
    cy.url().should('include', '/cart')

    // Proceed to checkout
    cy.get('[data-testid="checkout-button"]').click()
    cy.url().should('include', '/checkout')

    // Fill shipping information
    cy.get('[data-testid="shipping-form"]').within(() => {
      cy.get('input[name="name"]').type('John Doe')
      cy.get('input[name="street"]').type('123 Main St')
      cy.get('input[name="city"]').type('Los Angeles')
      cy.get('input[name="state"]').type('CA')
      cy.get('input[name="postal_code"]').type('90210')
      cy.get('button[type="submit"]').click()
    })

    // Fill payment information (using Stripe test card)
    cy.get('[data-testid="payment-form"]').within(() => {
      cy.get('iframe[name="stripe-card-element"]').then($iframe => {
        const $body = $iframe.contents().find('body')
        cy.wrap($body)
          .find('input[name="cardnumber"]')
          .type('4242424242424242')
        cy.wrap($body)
          .find('input[name="exp-date"]')
          .type('1234')
        cy.wrap($body)
          .find('input[name="cvc"]')
          .type('123')
      })
      cy.get('button[type="submit"]').click()
    })

    // Verify order confirmation
    cy.url().should('include', '/orders/confirmation')
    cy.get('[data-testid="order-confirmation"]').should('be.visible')
    cy.get('[data-testid="order-number"]').should('exist')

    // Verify email receipt
    cy.mailhog()
      .then(emails => {
        const lastEmail = emails[0]
        expect(lastEmail.to[0].address).to.equal('test@example.com')
        expect(lastEmail.subject).to.include('Order Confirmation')
      })
  })

  it('handles payment errors gracefully', () => {
    cy.visit('/products')
    
    // Add product and go to checkout
    cy.get('[data-testid="product-card"]').first().within(() => {
      cy.get('[data-testid="add-to-cart"]').click()
    })
    cy.get('[data-testid="cart-icon"]').click()
    cy.get('[data-testid="checkout-button"]').click()

    // Fill shipping info
    cy.get('[data-testid="shipping-form"]').within(() => {
      cy.get('input[name="name"]').type('John Doe')
      cy.get('input[name="street"]').type('123 Main St')
      cy.get('input[name="city"]').type('Los Angeles')
      cy.get('input[name="state"]').type('CA')
      cy.get('input[name="postal_code"]').type('90210')
      cy.get('button[type="submit"]').click()
    })

    // Use a declined card
    cy.get('[data-testid="payment-form"]').within(() => {
      cy.get('iframe[name="stripe-card-element"]').then($iframe => {
        const $body = $iframe.contents().find('body')
        cy.wrap($body)
          .find('input[name="cardnumber"]')
          .type('4000000000000002') // Declined card
        cy.wrap($body)
          .find('input[name="exp-date"]')
          .type('1234')
        cy.wrap($body)
          .find('input[name="cvc"]')
          .type('123')
      })
      cy.get('button[type="submit"]').click()
    })

    // Verify error message
    cy.get('[data-testid="payment-error"]')
      .should('be.visible')
      .and('contain', 'Your card was declined')
  })
}) 