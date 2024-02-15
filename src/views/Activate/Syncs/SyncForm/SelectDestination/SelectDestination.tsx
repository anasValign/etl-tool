import ContentContainer from "@/components/ContentContainer";
import Loader from "@/components/Loader";
import { SteppedFormContext } from "@/components/SteppedForm/SteppedForm";
import { getUserConnectors } from "@/services/connectors";
import DestinationsTable from "@/views/Connectors/Destinations/DestinationsList/DestinationsTable";
import NoConnectors from "@/views/Connectors/NoConnectors";
import { DESTINATIONS_LIST_QUERY_KEY } from "@/views/Connectors/constant";
import { Box } from "@chakra-ui/react";
import { useQuery } from "@tanstack/react-query";
import { useContext } from "react";

const SelectDestination = (): JSX.Element => {
  const { stepInfo, handleMoveForward } = useContext(SteppedFormContext);

  const handleOnRowClick = (data: Record<"connector", unknown>) => {
    handleMoveForward(stepInfo?.formKey as string, data?.connector);
  };

  const { data, isLoading } = useQuery({
    queryKey: DESTINATIONS_LIST_QUERY_KEY,
    queryFn: () => getUserConnectors("destination"),
    refetchOnMount: false,
    refetchOnWindowFocus: false,
  });

  if (isLoading && !data) return <Loader />;

  if (data?.data.length === 0)
    return <NoConnectors connectorType="destination" />;

  return (
    <Box width="100%" display="flex" justifyContent="center">
      <ContentContainer>
        {isLoading || !data ? (
          <Loader />
        ) : (
          <DestinationsTable
            handleOnRowClick={(data) => handleOnRowClick(data)}
            destinationData={data}
            isLoading={isLoading}
          />
        )}
      </ContentContainer>
    </Box>
  );
};

export default SelectDestination;
