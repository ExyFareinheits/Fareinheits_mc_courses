import { Routes, Route } from 'react-router-dom'
import Layout from './components/Layout'
import Home from './pages/Home'
import Courses from './pages/Courses'
import CourseDetail from './pages/CourseDetail'
import CourseLearning from './pages/CourseLearning'
import Profile from './pages/Profile'
import Admin from './pages/Admin'
import RequestAccess from './pages/RequestAccess'
import About from './pages/About'

function App() {
  return (
    <Layout>
      <Routes>
        <Route path="/" element={<Home />} />
        <Route path="/courses" element={<Courses />} />
        <Route path="/courses/:slug" element={<CourseDetail />} />
        <Route path="/learn/:slug" element={<CourseLearning />} />
        <Route path="/profile" element={<Profile />} />
        <Route path="/request-access" element={<RequestAccess />} />
        <Route path="/admin" element={<Admin />} />
        <Route path="/about" element={<About />} />
      </Routes>
    </Layout>
  )
}

export default App
