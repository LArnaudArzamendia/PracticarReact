import LoginForm from './components/LoginForm';

function App() {
  const handleLoginSuccess = () => {
    // Here you could fetch /bootstrap data if you had an endpoint,
    // or navigate to a protected route later. For now, nothing else needed.
  };

  return (
    <>
      <h1>TravelLog</h1>
      <LoginForm onSuccess={handleLoginSuccess} />
    </>
  );
}

export default App;
