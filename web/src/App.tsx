import {useEffect, useState} from "react";
import {Button, Form, Table} from "react-bootstrap";

function App() {
  const [type, setType] = useState<undefined | any[]>(undefined);
  const [selectedType, setSelectedType] = useState<undefined | string>(undefined);
  const [fetchData, setFetchData] = useState<undefined | any[]>(undefined);

  const search = () => {
    if (!selectedType) {
      alert('타입을 선택하세요.');
      setFetchData(undefined);
      return;
    }

    fetch(`/api/generateData?type=${selectedType}`)
        .then(data => data.json())
        .then(setFetchData)
  }

  const buildTable = (): JSX.Element => {
    if (!fetchData) return <></>;

    const keys = Object.keys(fetchData[0]);

    return(
      <div className='mt-4 h-100 overflow-auto'>
        <Table striped bordered hover size="sm">
          <thead>
            <tr>
              <th>#</th>
              {
                keys.map((dt, idx) => {
                  return <th key={idx}>{dt}</th>
                })
              }
            </tr>
          </thead>
          <tbody>
          {
            fetchData.map((dt, idx) => {
              return (
                  <tr key={idx}>
                    <td>{idx + 1}</td>
                    {
                      keys.map((key, idx2) => {
                        return <td key={idx2}>{dt[key]}</td>
                      })
                    }
                  </tr>
              )
            })
          }
          </tbody>
        </Table>
      </div>
    )
  }

  useEffect(() => {
    fetch('/api/getType')
        .then(data => data.json())
        .then(setType)
  }, [])

  return (
    <div className="d-flex justify-content-center align-items-center h-100">
      <div className='w-50 h-50'>
        <div className='d-flex'>
          <Form.Select style={{ flex: 5 }} value={selectedType} onChange={e => setSelectedType(e.target.value)}>
            <option value=''>타입을 선택하세요.</option>
            {type && type.map(data => {
              return <option value={data.value} key={data.value}>{data.name}</option>
            })}
          </Form.Select>
          <Button variant="primary" className='ms-3' style={{ flex: 1 }} onClick={search}>검색</Button>
        </div>
        {buildTable()}
      </div>
    </div>
  )
}

export default App
