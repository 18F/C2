describe TestUseCaseController do
  it "rescues from pundit error and redirects" do
    controller.stub(:edit).and_raise(Pundit::NotAuthorizedError)

    get :edit

    expect(response.code).to eq 403
  end
end

class TestUseCaseController < UseCasesController

end
